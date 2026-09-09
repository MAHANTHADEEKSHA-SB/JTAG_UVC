// Shared JTAG UVC enums, transaction-carrying structs, and TAP graph
// navigation utilities. Included once, in this position, by jtag_pkg.sv.

typedef enum {
  TEST_LOGIC_RESET,
  RUN_TEST_IDLE,
  SELECT_DR_SCAN,
  CAPTURE_DR,
  SHIFT_DR,
  EXIT1_DR,
  PAUSE_DR,
  EXIT2_DR,
  UPDATE_DR,
  SELECT_IR_SCAN,
  CAPTURE_IR,
  SHIFT_IR,
  EXIT1_IR,
  PAUSE_IR,
  EXIT2_IR,
  UPDATE_IR
} jtag_tap_state_e;

typedef enum {
  JTAG_OP_RESET,
  JTAG_OP_SCAN
} jtag_op_kind_e;

typedef enum {
  JTAG_SCAN_IR,
  JTAG_SCAN_DR
} jtag_scan_kind_e;

typedef enum {
  JTAG_RESET_TMS,
  JTAG_RESET_TRST
} jtag_reset_kind_e;

typedef enum {
  JTAG_STATUS_OK,
  JTAG_STATUS_INTERRUPTED,
  JTAG_STATUS_ERROR
} jtag_status_e;

typedef enum {
  JTAG_OBS_RESET,
  JTAG_OBS_SCAN
} jtag_obs_kind_e;

// Driver-proxy request/response for a single scan operation (IR or DR).
typedef struct {
  jtag_scan_kind_e kind;
  int unsigned      length;      // number of bits; data[0] shifted in first
  bit               data[];
  jtag_tap_state_e  end_state;   // legal targets: RUN_TEST_IDLE, PAUSE_IR, PAUSE_DR
} jtag_scan_req_s;

typedef struct {
  jtag_scan_kind_e kind;
  int unsigned      length;
  bit               data[];      // captured TDO bits; data[0] captured first
  jtag_status_e     status;
} jtag_scan_rsp_s;

// Monitor-proxy observation, covering both scan activity and reset events.
typedef struct {
  jtag_obs_kind_e   obs_kind;
  jtag_scan_kind_e  scan_kind;   // valid when obs_kind == JTAG_OBS_SCAN
  int unsigned      length;
  bit               tdi_data[];
  bit               tdo_data[];
  jtag_tap_state_e  end_state;
  jtag_status_e     status;
  time              timestamp;
} jtag_observation_s;

// Standard IEEE 1149.1 TAP state graph: the state reached from `cur` after
// one TCK rising edge with the given TMS value.
function automatic jtag_tap_state_e jtag_tap_next_state(jtag_tap_state_e cur, bit tms);
  case (cur)
    TEST_LOGIC_RESET: jtag_tap_next_state = tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
    RUN_TEST_IDLE:     jtag_tap_next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
    SELECT_DR_SCAN:    jtag_tap_next_state = tms ? SELECT_IR_SCAN   : CAPTURE_DR;
    CAPTURE_DR:        jtag_tap_next_state = tms ? EXIT1_DR         : SHIFT_DR;
    SHIFT_DR:          jtag_tap_next_state = tms ? EXIT1_DR         : SHIFT_DR;
    EXIT1_DR:          jtag_tap_next_state = tms ? UPDATE_DR        : PAUSE_DR;
    PAUSE_DR:          jtag_tap_next_state = tms ? EXIT2_DR         : PAUSE_DR;
    EXIT2_DR:          jtag_tap_next_state = tms ? UPDATE_DR        : SHIFT_DR;
    UPDATE_DR:         jtag_tap_next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
    SELECT_IR_SCAN:    jtag_tap_next_state = tms ? TEST_LOGIC_RESET : CAPTURE_IR;
    CAPTURE_IR:        jtag_tap_next_state = tms ? EXIT1_IR         : SHIFT_IR;
    SHIFT_IR:          jtag_tap_next_state = tms ? EXIT1_IR         : SHIFT_IR;
    EXIT1_IR:          jtag_tap_next_state = tms ? UPDATE_IR        : PAUSE_IR;
    PAUSE_IR:          jtag_tap_next_state = tms ? EXIT2_IR         : PAUSE_IR;
    EXIT2_IR:          jtag_tap_next_state = tms ? UPDATE_IR        : SHIFT_IR;
    UPDATE_IR:         jtag_tap_next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
    default:           jtag_tap_next_state = TEST_LOGIC_RESET;
  endcase
endfunction

// Breadth-first search over the 16-state TAP graph for a TMS bit sequence
// from `from_state` to `to_state`. Every state can reach every other state
// in the standard graph, so an empty result on a non-trivial request
// indicates a bug in this function rather than a real dead end.
function automatic void jtag_tap_compute_path(
  input  jtag_tap_state_e from_state,
  input  jtag_tap_state_e to_state,
  output bit              tms_path[$]
);
  jtag_tap_state_e prev_state [16];
  bit              prev_tms   [16];
  bit              visited    [16];
  jtag_tap_state_e bfs_q      [$];
  jtag_tap_state_e cur, nxt0, nxt1, walk;
  bit              path_rev   [$];

  tms_path.delete();
  if (from_state == to_state) return;

  foreach (visited[i]) visited[i] = 1'b0;
  visited[int'(from_state)] = 1'b1;
  bfs_q.push_back(from_state);

  while (bfs_q.size() > 0) begin
    cur = bfs_q.pop_front();
    if (cur == to_state) break;

    nxt0 = jtag_tap_next_state(cur, 1'b0);
    nxt1 = jtag_tap_next_state(cur, 1'b1);

    if (!visited[int'(nxt0)]) begin
      visited[int'(nxt0)]    = 1'b1;
      prev_state[int'(nxt0)] = cur;
      prev_tms[int'(nxt0)]   = 1'b0;
      bfs_q.push_back(nxt0);
    end
    if (!visited[int'(nxt1)]) begin
      visited[int'(nxt1)]    = 1'b1;
      prev_state[int'(nxt1)] = cur;
      prev_tms[int'(nxt1)]   = 1'b1;
      bfs_q.push_back(nxt1);
    end
  end

  if (!visited[int'(to_state)]) return;

  walk = to_state;
  while (walk != from_state) begin
    path_rev.push_back(prev_tms[int'(walk)]);
    walk = prev_state[int'(walk)];
  end
  for (int i = path_rev.size() - 1; i >= 0; i--) tms_path.push_back(path_rev[i]);
endfunction
