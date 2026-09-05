// apb_readonly_write_error_check_seq.sv
class apb_readonly_write_error_check_seq extends apb_base_seq;
  `uvm_object_utils(apb_readonly_write_error_check_seq)
  function new(string name = "apb_readonly_write_error_check_seq"); super.new(name); endfunction

  task body();
    apb_seq_item item;
    bit first_result_captured = 0;
    bit expected_pslverr;

    if (reg_model == null) `uvm_fatal("SEQ_ERR", "reg_model not set");

    foreach (reg_model.regs[i]) begin
      if (!reg_model.regs[i].is_read_only) continue;

      item = apb_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with { paddr == i * 4; pwrite == 1; pwdata == 32'hBAD0_BAD0; })
        `uvm_error("SEQ_ERR", "randomize failed in readonly_write_error_check");
      finish_item(item);

      if (!first_result_captured) begin
        expected_pslverr = item.pslverr;
        first_result_captured = 1;
        `uvm_info("SEQ_INFO", $sformatf(
          "DUT RO-write response established: pslverr=%0b (documenting as ground truth)",
          expected_pslverr), UVM_LOW)
      end else if (item.pslverr !== expected_pslverr) begin
        `uvm_error("SEQ_ERR", $sformatf(
          "INCONSISTENT RO-write response: reg[%0d] gave pslverr=%0b, expected %0b",
          i, item.pslverr, expected_pslverr))
      end
    end
  endtask
endclass
