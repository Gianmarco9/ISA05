class packet_in extends uvm_sequence_item;
    rand logic [nb-1:0] A;
    rand logic [nb-1:0] B;

    // no subnormal result
    constraint my_range { (A[30:23] + B[30:23] - 127) inside {[0:254]}; }
    // no subnormal factors
    constraint my_range1{ (A[30:23] * B[30:23]) != 0; }
    // no special factors (NaN & inf)
    constraint my_range2{ A[30:23] < 255; B[30:23] < 255; }

    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
        super.new(name);
    endfunction: new
endclass: packet_in
