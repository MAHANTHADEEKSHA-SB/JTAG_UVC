# JTAG UVC architecture and advantages

Status: proposed architecture, based on design discussion. Component boundaries below are the intended baseline; API and timing details require agreement before implementation.

## Objective

Build a reusable SystemVerilog/UVM JTAG UVC with a common signal interface, separate driver and monitor bus functional models (BFMs), and proxy classes separating UVM components from concrete signal-access implementations.

The initial working assumption is an active JTAG controller driving a DUT TAP, with a passive monitoring mode. Additional roles remain outside the initial scope until specified.

## Structure

```text
jtag_agent
 |-- jtag_agent_config
 |-- jtag_sequencer --> jtag_driver
 |                         |
 |                  driver proxy handle
 |                         |
 |                  concrete driver proxy
 |                         |
 |                    driver BFM
 |                         |
 |                    common jtag_if <--> DUT TAP
 |                         |
 |                    monitor BFM
 |                         |
 |                 concrete monitor proxy
 |                         |
 |-- jtag_monitor <-- monitor proxy handle
         |
      analysis port --> environment subscribers/checkers/coverage
```

The arrows describe communication, not inheritance. Driver and monitor proxy handles are typed as separate abstract base classes. Their concrete implementations inherit those bases.

## Responsibilities

| Element | Responsibility |
| --- | --- |
| `jtag_if` | Declare common TCK, TMS, TDI, TDO and optional-reset connectivity; define appropriate signal-access views and timing constructs. |
| Driver BFM | Own controller-side pin driving and timing; execute requested operations and return sampled TDO data. |
| Monitor BFM | Observe pins independently; report actual protocol activity, reset, and interrupted operations. Never drive bus pins. |
| Driver proxy base | Define the abstract callable contract used by the UVM driver. |
| Monitor proxy base | Define the abstract observation contract used by the UVM monitor. |
| Concrete proxies | Adapt abstract calls to the corresponding BFM instance. |
| `jtag_driver` | Consume sequence items, invoke the driver proxy, and complete the UVM request/response handshake. |
| `jtag_monitor` | Obtain observations through the monitor proxy and publish monitor transactions through an analysis port. |
| `jtag_sequencer` | Arbitrate sequence requests for the driver. |
| `jtag_agent_config` | Hold per-instance settings and proxy handles. |
| `jtag_agent` | Build and connect components; enable driver/sequencer only in active mode. |
| Shared package(s) | Define common enums, data types, abstract contracts, and UVM classes in an explicit dependency order. |

The BFMs receive the common `jtag_if` instance through an interface port. A proposed implementation uses separate BFM interfaces, each containing a concrete proxy implementation that calls its enclosing BFM's tasks. Confirm simulator acceptance with a minimal compile test before building the full UVC.

## Base-class policy

Use project-specific bases for the agreed extension points: agent, driver, monitor, sequencer, sequence item, sequence, and the two proxy contracts. Component bases inherit the appropriate UVM classes; concrete implementations inherit the project bases. Parameterization required by standard UVM APIs, such as `uvm_driver #(jtag_item)`, remains normal and acceptable.

Keep the hierarchy shallow. Base classes should define useful contracts or shared behavior. Configuration and simple data objects can inherit directly from `uvm_object`; whether they also require project-specific bases is an open naming/extension policy decision.

Separate driver and monitor proxy contracts normally require two abstract classes and two concrete implementations. No additional forwarding-wrapper layer is intended.

## Parameters, packages, and runtime configuration

Avoid propagating interface-width parameters through the agent, driver, monitor, sequencer, and transaction hierarchy. Proxies expose stable types while concrete implementations contain any necessary interface specialization.

For basic serial JTAG, scan length does not change pin widths. Start with an unparameterized common interface, runtime scan lengths, and dynamically sized scan data. Use elaboration parameters only when actual static structure requires them.

| Information | Intended location |
| --- | --- |
| TAP-state and operation enums | Shared definitions package |
| Abstract BFM contracts | Proxy/API package or dependency-safe shared package |
| IR length or chain description | Per-agent configuration |
| TCK timing and reset policy | Per-agent configuration, with legal timing validation |
| Scan length, outgoing data, requested end state | Request transaction |
| Captured data and completion/interruption status | Response or observation transaction |
| True static structural variation | Interface/BFM parameters, if needed |

A package supplies shared declarations and constants; it is not instantiated with per-agent parameter overrides. Putting an instance-specific IR width into a single package constant would couple agents that need different widths. Package organization and proxy abstraction solve different problems and should be used together.

## BFM contracts and ownership

Prefer operation-level driver calls initially: request a scan or reset operation and receive its result. This reduces calls across the proxy boundary compared with invoking a method for every bit. The driver BFM therefore owns the pin-level execution and the TAP navigation needed for these operations.

The monitor BFM independently reconstructs observed protocol activity from pins. The UVM monitor publishes the resulting observations. It must report reset and interrupted scans as well as completed scans; reporting only successful completion would hide important behavior.

Exact APIs remain open. They must define blocking behavior, buffer ownership, completion status, reset interruption, legal end states, and cancellation. A future cycle-level diagnostic API can be added if justified without making it the default transaction path.

The driver owns its predicted state for generating traffic. The monitor owns a separate observed state. Shared type definitions are appropriate; sharing the driver's mutable state or intended transactions as the monitor's source of truth is not.

## Instance binding and startup

1. The testbench top instantiates the common interface, BFMs, and DUT connections.
2. Each BFM supplies a concrete proxy associated with that BFM instance.
3. Testbench setup places abstract proxy handles in the corresponding agent configuration.
4. Configuration is published before UVM build retrieves it and before traffic starts.
5. The agent validates the required handles and settings; missing connections cause a clear fatal configuration error.

Use explicit per-instance binding rather than a global singleton or broad factory override. In passive mode, require only the monitor connection and ensure the driver BFM does not generate TCK or drive pins. Define an explicit startup handshake or ordered setup to prevent time-zero registration races.

## Advantages

1. **Stable UVM component types.** Concrete interface details remain behind the proxy API, avoiding unnecessary width-dependent specializations across the class hierarchy.
2. **Independent agent configurations.** Multiple agents can use different scan and TAP settings while sharing the same component classes.
3. **Clear timing ownership.** Pin-level actions belong to BFMs; sequencing and UVM integration belong to classes.
4. **Replaceable implementations.** A different BFM can implement the same contract without rewriting the agent or driver. A substitute proxy can also exercise class-level behavior without a DUT, although that does not validate bus timing.
5. **Independent observation.** Separate monitor logic checks what happened on the pins, including behavior that differs from the driver's intention.
6. **Common connectivity definition.** A single signal interface keeps pin naming and access views consistent.
7. **Controlled extension points.** Base classes provide deliberate customization points without copying entire components.
8. **Potentially lower specialization overhead.** If the alternative generates many parameterized class types, abstract handles can reduce that compile burden. This is conditional, not a measured performance result.

## Trade-offs and limitations

| Concern | Assessment and response |
| --- | --- |
| Additional classes | Two abstract and two concrete proxy classes add setup code; keep them small and avoid redundant wrappers. |
| Runtime dispatch | Virtual calls add indirection. Operation-level calls limit frequency, but speed benefits require measurement. |
| More BFM protocol logic | Operation-level APIs move TAP navigation and scan reconstruction into BFMs; document and test these responsibilities explicitly. |
| Debugging across layers | Use clear operation IDs, errors, and documented ownership rather than verbose per-cycle logging by default. |
| Startup ordering | Establish proxy/configuration binding before UVM build and traffic. |
| Observation buffering | Define queue limits, ordering, and overflow behavior so slow consumers cannot silently lose activity. |
| Four-state observations | Preserve X/Z information where meaningful; do not silently coerce observed pins into two-state data. |
| Static parameterization | Proxies hide specialized types; they do not remove elaboration-time requirements. |
| Emulation | This architecture alone does not establish synthesizability or emulation compatibility. |

No compile-time, memory, or simulator-speed improvement has been measured. Logging, waveform dumping, per-cycle work, and allocation patterns may matter more than the small number of proxy objects.

## Alternatives considered

| Alternative | When useful | Why not the selected baseline |
| --- | --- | --- |
| Direct virtual BFM interface handles | Small UVC with stable, unparameterized interfaces | Simpler wiring, but UVM classes depend on concrete BFM interface types. |
| Parameterized UVM hierarchy | Static type/width specialization is genuinely needed throughout | Can spread type parameters and configuration complexity across components. |
| Package constants for configuration | Values intentionally shared across the entire build | Cannot provide independent per-agent overrides of one package constant. |
| Proxy-based BFM access | Reusable component contracts and multiple implementations | Selected; modest extra structure earns its place through decoupling. |

## Validation plan

Initial target: EDA Playground, UVM 1.2, and a compatible simulator such as Riviera-PRO when available to the account. Keep local files as the authoritative source and retain run logs with the exact source revision and settings.

Validate incrementally:

1. Compile a minimal common interface, both BFMs, abstract/concrete proxies, and UVM handle binding.
2. Demonstrate two independently bound instances with different runtime configurations.
3. Verify passive mode produces no driven traffic.
4. Exercise reset and basic IR/DR scans against a small TAP DUT.
5. Check captured data, TAP transitions, timing, and requested end states using independent expectations.
6. Exercise reset during a scan, interrupted activity, and relevant X/Z behavior.
7. Confirm injected DUT/protocol faults are detected rather than merely checking that normal traffic passes.

Compilation success is not protocol verification. No implementation or simulation has been performed as part of this architecture document.

## Decisions still to settle

- Exact driver and monitor proxy method signatures and data ownership.
- Reset support: TMS reset, optional TRST, and interruption semantics.
- Supported TAP chains and the representation of chain/device configuration.
- TCK ownership, idle behavior, and exact drive/sample timing.
- Monitor event types, buffering, and recovery after unknown or interrupted activity.
- Project-specific base requirements for configuration and observation classes.
- Package/file dependency order and minimal simulator portability checks.

## References

- [Doulos: parameterized interface example](https://www.doulos.com/knowhow/systemverilog/uvm/easier-uvm/easier-uvm-deeper-explanations/parameterized-interface-example/) — abstract/concrete classes isolating generic UVM components from parameterized interfaces.
- [Accellera: package parameter discussion](https://www.accellera.org/images/eda/sv-bc/1199.html) — historical language-design discussion about non-overridable package parameters; not a substitute for the current language standard.
- [EDA Playground settings](https://eda-playground.readthedocs.io/en/latest/settings.html) — source files, UVM selection, results, and waveform options.
