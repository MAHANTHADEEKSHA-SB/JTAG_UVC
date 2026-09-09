// Project extension point for the driver.
class jtag_base_driver extends uvm_driver #(jtag_item);
  `uvm_component_utils(jtag_base_driver)

  function new(string name = "jtag_base_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
