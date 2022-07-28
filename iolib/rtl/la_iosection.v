/*****************************************************************************
 * Function: IO padring section
 * Copyright: Lambda Project Authors. ALl rights Reserved.
 * License:  MIT (see LICENSE file in Lambda repository)
 *
 ****************************************************************************/

module la_iosection
  #(parameter N         =  8,        // total bidir pads (in section)
    parameter NANALOG   =  0,        // total analog pads
    parameter NVDDIO    =  1,        // total IO supply pads
    parameter NVDD      =  1,        // total core supply pads
    parameter NGND      =  1,        // total core ground pads
    parameter NDECAP    =  0,        // total decap cells
    parameter CFGW      =  8,        // width of core config bus
    parameter RINGW     =  8,        // width of io ring
    parameter SIDE      = "NO",      // "NO", "SO", "EA", "WE"
    parameter IOTYPE    = "DEFAULT", // io cell type
    parameter POCTYPE   = "DEFAULT", // poc cell type
    parameter VDDTYPE   = "DEFAULT", // vdd cell type
    parameter VDDIOTYPE = "DEFAULT", // vddio cell type
    parameter VSSIOTYPE = "DEFAULT", // vssio cell type
    parameter VSSTYPE   = "DEFAULT"  // vss cell type
    )
   (// io pad signals
    inout [N-1:0]      pad, // pad
    inout 	       vss, // common ground
    // signals with breakers
    inout 	       vdd, // core supply
    inout 	       vddio, // io supply
    inout 	       vssio, // io ground
    inout [RINGW-1:0]  ioring, // generic io-ring
    //core facing signals
    input [N-1:0]      a, // input from core
    output [N-1:0]     z, // output to core
    input [N-1:0]      ie, // input enable, 1 = active
    input [N-1:0]      oe, // output enable, 1 = active
    input [N-1:0]      pe, // pullup enable, 1 = active
    input [N-1:0]      ps, // pullup select, 1 = pull-up, 0 = pull-down
    input [N-1:0]      sr, // slewrate enable 1 = slow, 1 = fast
    input [N-1:0]      st, // schmitt trigger, 1 = enable
    input [N*2-1:0]    ds, // drive strength, 3'b0 = weakest
    input [N*CFGW-1:0] cfg // generic config interface
    );

   genvar 	       i;

   //##########################################
   //# BIDIR BUFFERS
   //##########################################

   for(i=0;i<N;i=i+1)
     begin
	la_iobidir #(.SIDE(SIDE),
		     .TYPE(IOTYPE),
		     .CFGW(CFGW),
		     .RINGW(RINGW))
	ibidir (// Outputs
		.z	(z[i]),
		// Inouts
		.pad	(pad[i]),
		.vdd	(vdd),
		.vss	(vss),
		.vddio  (vddio),
		.vssio	(vssio),
		.ioring	(ioring[RINGW-1:0]),
		// Inputs
		.a	(a[i]),
		.ie	(ie[i]),
		.oe	(oe[i]),
		.pe	(pe[i]),
		.ps	(ps[i]),
		.sr	(sr[i]),
		.st	(st[i]),
		.ds	(ds[i*3+:3]),
		.cfg	(cfg[i*CFGW+:CFGW]));
     end

   //##########################################
   //# ANALOG
   //##########################################

   for(i=0;i<NANALOG;i=i+1)
     begin
	la_ioanalog #(.SIDE(SIDE),
		      .TYPE(IOTYPE),
		      .RINGW(RINGW))
	ipin (.pad    (pad[i]),
	      .vdd    (vdd),
	      .vss    (vss),
	      .vddio  (vddio),
	      .vssio  (vssio),
	      .a      (a[i]),
	      .z      (z[i]),
	      .ioring (ioring[RINGW-1:0]));
     end

   //##########################################
   //# VDDIO/VSSIO
   //##########################################

   for(i=0;i<NVDDIO;i=i+1)
     begin
	// vddio
	la_iovddio #(.SIDE(SIDE),
		     .TYPE(VDDIOTYPE),
		     .RINGW(RINGW))
	ivddio (.vdd     (vdd),
		.vss     (vss),
		.vddio   (vddio),
		.vssio   (vssio),
		.ioring  (ioring[RINGW-1:0]));

	// vssio
	la_iovssio #(.SIDE(SIDE),
		     .TYPE(VSSIOTYPE),
		     .RINGW(RINGW))
	ivssio (.vdd     (vdd),
		.vss     (vss),
		.vddio   (vddio),
		.vssio   (vssio),
		.ioring  (ioring[RINGW-1:0]));
     end

   //##########################################
   //# VDD
   //##########################################

   for(i=0;i<NVDD;i=i+1)
     begin
	la_iovdd #(.SIDE(SIDE),
		   .TYPE(VDDTYPE),
		   .RINGW(RINGW))
	ivdd (.vdd     (vdd),
	      .vss     (vss),
	      .vddio   (vddio),
	      .vssio   (vssio),
	      .ioring  (ioring[RINGW-1:0]));
     end

   //##########################################
   //# VSS
   //##########################################

   for(i=0;i<NGND;i=i+1)
     begin
	la_iovss #(.SIDE(SIDE),
		   .TYPE(VSSTYPE),
		   .RINGW(RINGW))
	ivss (.vdd     (vdd),
	      .vss     (vss),
	      .vddio   (vddio),
	      .vssio   (vssio),
	      .ioring  (ioring[RINGW-1:0]));
     end

   //#########################################
   //# POWER ON CONTROL
   //#########################################

   la_iopoc #(.SIDE(SIDE),
	      .TYPE(POCTYPE),
	      .RINGW(RINGW))
   ipoc (.vdd     (vdd),
	 .vss     (vss),
	 .vddio   (vddio),
	 .vssio   (vssio),
	 .ioring  (ioring[RINGW-1:0]));

endmodule
// Local Variables:
// verilog-library-directories:("." )
// End:
