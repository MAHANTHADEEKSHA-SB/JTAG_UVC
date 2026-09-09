// Abstract contract used by jtag_monitor to reach a concrete monitor BFM.
// get_observation() blocks until the BFM has an observation ready (scan
// completion or reset) and must report interrupted/reset activity, not
// only successful completions.
virtual class jtag_base_monitor_proxy;
  pure virtual task get_observation(output jtag_observation_s obs);
endclass
