`timescale 1ns/1ps     // rs16.v  ** (C) Copyright MMXXII Certus Semiconductor ** 2022.1118

// VDDIO=1.20/1.50/1.80 Banks
module RS_HP_VDD_EW       (input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDD18_EW     (input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDDIO_EW     (input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDDIO_POC_EW (input [6:0] AICN,AICP, inout POC, inout VDD,VDDIO,VDD18,VREF,VSS); pullup(POC); endmodule
module RS_HP_VREF_EW      (input [6:0] AICN,AICP, input EN,POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDD_NS       (input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDD18_NS     (input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDDIO_NS     (input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HP_VDDIO_POC_NS (input [6:0] AICN,AICP, inout POC, inout VDD,VDDIO,VDD18,VREF,VSS); pullup(POC); endmodule
module RS_HP_VREF_NS      (input [6:0] AICN,AICP, input EN,POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule

module RS_HP_VDDIO_TERM_EW (input [6:0] AICN,AICP,AICNX,AICPX, input PGEN,POC, inout VDD,VDDIO,VDD18,VREF,VSS);
    rtranif1 b110[6:0](AICN,AICNX,POC&PGEN); rtranif1 b011[6:0](AICP,AICPX,POC&PGEN); endmodule
module RS_HPIO_RCAL_EW (inout IO, output DOUT, input CK,DIN,IE,MSTR,OE,PE,PUD,RST,
    inout [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS);
    rtranif1(IO,PUD,POC&!MSTR&PE); bufif1(IO,DIN,POC&!MSTR&OE); buf(DOUT,POC&!MSTR&IE&IO);
    bufif1 aicn[6:0](AICN,~RST,POC&MSTR); bufif1 aicp[6:0](AICP,RST,POC&MSTR); specify
    (DIN=>IO)=(0.2,0.2); (OE=>IO)=(0.2,0.2,0.2,0.2,0.2,0.2); (IO=>DOUT)=(0.2,0.2); (IE=>DOUT)=(0.2,0.2);
endspecify endmodule
module RS_HPIO_DIF_EW (inout IOA,IOB, // 1.2V-1.8V IO PADS
    output CDETA,DOUTA, input DINA,IEA,OEA,PEA,PUDA,SRA, input [3:0] MCA,
    output CDETB,DOUTB, input DINB,IEB,OEB,PEB,PUDB,SRB, input [3:0] MCB,
    output DFRX, input DFTX,DFEN,DFRXEN,DFTXEN,DFODTEN,
    input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS);
    wire MIPI=DFEN&(MCA[3:1]==3'b011),MIPD=DFEN&(MCA==4'b0111),LVC=!DFEN&!MCA[3];
    rtranif1(IOA,PUDA,POC&LVC&PEA);  rtranif1(IOB,PUDB,POC&LVC&PEB);
    bufif1 txa(IOA, DFEN?(MIPI?(DFTXEN? DFTX:DINA): DFTX):DINA, POC&(DFEN?DFTXEN|(MIPI&OEA):OEA));
    bufif1 txb(IOB, DFEN?(MIPI?(DFTXEN?~DFTX:DINB):~DFTX):DINB, POC&(DFEN?DFTXEN|(MIPI&OEB):OEB));
    buf  rxa(DOUTA, POC&IEA&(!DFEN|MIPI)?IOA:1'b0); buf(CDETA,POC&MIPD&(IOA===1'bX));
    buf  rxb(DOUTB, POC&IEB&(!DFEN|MIPI)?IOB:1'b0); buf(CDETB,POC&MIPD&(IOB===1'bX));
    buf  rxd(DFRX,  POC&DFRXEN&DFEN?((IOA===1'b0)&(IOB===1'b1)?1'b0:((IOA===1'b1)&(IOB===1'b0)?1'b1:1'bX)):1'b0);
specify
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);

if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);

endspecify endmodule

module RS_HP_VDDIO_TERM_NS (input [6:0] AICN,AICP,AICNX,AICPX, input PGEN,POC, inout VDD,VDDIO,VDD18,VREF,VSS);
    rtranif1 b110[6:0](AICN,AICNX,POC&PGEN); rtranif1 b011[6:0](AICP,AICPX,POC&PGEN); endmodule
module RS_HPIO_RCAL_NS (inout IO, output DOUT, input CK,DIN,IE,MSTR,OE,PE,PUD,RST,
    inout [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS);
    rtranif1(IO,PUD,POC&!MSTR&PE); bufif1(IO,DIN,POC&!MSTR&OE); buf(DOUT,POC&!MSTR&IE&IO);
    bufif1 aicn[6:0](AICN,~RST,POC&MSTR); bufif1 aicp[6:0](AICP,RST,POC&MSTR); specify
    (DIN=>IO)=(0.2,0.2); (OE=>IO)=(0.2,0.2,0.2,0.2,0.2,0.2); (IO=>DOUT)=(0.2,0.2); (IE=>DOUT)=(0.2,0.2);
endspecify endmodule
module RS_HPIO_DIF_NS (inout IOA,IOB, // 1.2V-1.8V IO PADS
    output CDETA,DOUTA, input DINA,IEA,OEA,PEA,PUDA,SRA, input [3:0] MCA,
    output CDETB,DOUTB, input DINB,IEB,OEB,PEB,PUDB,SRB, input [3:0] MCB,
    output DFRX, input DFTX,DFEN,DFRXEN,DFTXEN,DFODTEN,
    input [6:0] AICN,AICP, input POC, inout VDD,VDDIO,VDD18,VREF,VSS);
    wire MIPI=DFEN&(MCA[3:1]==3'b011),MIPD=DFEN&(MCA==4'b0111),LVC=!DFEN&!MCA[3];
    rtranif1(IOA,PUDA,POC&LVC&PEA);  rtranif1(IOB,PUDB,POC&LVC&PEB);
    bufif1 txa(IOA, DFEN?(MIPI?(DFTXEN? DFTX:DINA): DFTX):DINA, POC&(DFEN?DFTXEN|(MIPI&OEA):OEA));
    bufif1 txb(IOB, DFEN?(MIPI?(DFTXEN?~DFTX:DINB):~DFTX):DINB, POC&(DFEN?DFTXEN|(MIPI&OEB):OEB));
    buf  rxa(DOUTA, POC&IEA&(!DFEN|MIPI)?IOA:1'b0); buf(CDETA,POC&MIPD&(IOA===1'bX));
    buf  rxb(DOUTB, POC&IEB&(!DFEN|MIPI)?IOB:1'b0); buf(CDETB,POC&MIPD&(IOB===1'bX));
    buf  rxd(DFRX,  POC&DFRXEN&DFEN?((IOA===1'b0)&(IOB===1'b1)?1'b0:((IOA===1'b1)&(IOB===1'b0)?1'b1:1'bX)):1'b0);
specify
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);

if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);         if ( DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);

endspecify endmodule

// VDDIO=1.80/2.50/3.30 Banks
module RS_HV_VDD_EW       (input HVEN,LVEN, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VDD_NS       (input HVEN,LVEN, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VDD18_EW     (input HVEN,LVEN, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VDD18_NS     (input HVEN,LVEN, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VDDIO_EW     (input HVEN,LVEN, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VDDIO_NS     (input HVEN,LVEN, input POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VDDIO_POC_EW (input HVEN,LVEN, inout POC, inout VDD,VDDIO,VDD18,VREF,VSS); pullup(POC); endmodule
module RS_HV_VDDIO_POC_NS (input HVEN,LVEN, inout POC, inout VDD,VDDIO,VDD18,VREF,VSS); pullup(POC); endmodule
module RS_HV_VREF_EW      (inout HVEN,LVEN, input EN,POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule
module RS_HV_VREF_NS      (inout HVEN,LVEN, input EN,POC, inout VDD,VDDIO,VDD18,VREF,VSS); endmodule

module RS_HVIO_DIF_EW (inout IOA,IOB, // 1.8V-3.3V IO PADS
    output DOUTA, input DINA,IEA,OEA,PEA,PUDA,SRA, input [3:0] MCA,
    output DOUTB, input DINB,IEB,OEB,PEB,PUDB,SRB, input [3:0] MCB,
    output DFRX, input DFTX,DFEN,DFRXEN,DFTXEN,
    input HVEN,LVEN,POC, inout VDD,VDDIO,VDD18,VREF,VSS); wire LVC=!DFEN&!MCA[3];
    rtranif1(IOA,PUDA,POC&LVC&PEA); rtranif1(IOB,PUDB,POC&LVC&PEB);
    bufif1 txa(IOA, DFEN? DFTX:DINA, POC&(DFEN?DFTXEN:OEA)); buf rxa(DOUTA, POC&IEA&!DFEN?IOA:1'b0);
    bufif1 txb(IOB, DFEN?~DFTX:DINB, POC&(DFEN?DFTXEN:OEB)); buf rxb(DOUTB, POC&IEB&!DFEN?IOB:1'b0);
    buf  rxd(DFRX,  POC&DFRXEN&DFEN?((IOA===1'b0)&(IOB===1'b1)?1'b0:((IOA===1'b1)&(IOB===1'b0)?1'b1:1'bX)):1'b0);
specify
if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);

if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!DFEN& MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);

if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!DFEN& MCB[3]& MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);

if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN&!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN&!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN&!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]& MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!DFEN& MCB[3]& MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!DFEN& MCB[3]& MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);

endspecify endmodule

module RS_HVIO_DIF_NS (inout IOA,IOB, // 1.8V-3.3V IO PADS
    output DOUTA, input DINA,IEA,OEA,PEA,PUDA,SRA, input [3:0] MCA,
    output DOUTB, input DINB,IEB,OEB,PEB,PUDB,SRB, input [3:0] MCB,
    output DFRX, input DFTX,DFEN,DFRXEN,DFTXEN,
    input HVEN,LVEN,POC, inout VDD,VDDIO,VDD18,VREF,VSS); wire LVC=!DFEN&!MCA[3];
    rtranif1(IOA,PUDA,POC&LVC&PEA); rtranif1(IOB,PUDB,POC&LVC&PEB);
    bufif1 txa(IOA, DFEN? DFTX:DINA, POC&(DFEN?DFTXEN:OEA)); buf rxa(DOUTA, POC&IEA&!DFEN?IOA:1'b0);
    bufif1 txb(IOB, DFEN?~DFTX:DINB, POC&(DFEN?DFTXEN:OEB)); buf rxb(DOUTB, POC&IEB&!DFEN?IOB:1'b0);
    buf  rxd(DFRX,  POC&DFRXEN&DFEN?((IOA===1'b0)&(IOB===1'b1)?1'b0:((IOA===1'b1)&(IOB===1'b0)?1'b1:1'bX)):1'b0);
specify
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]&!SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (DINA=>IOA)=(0.2,0.2);  if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]& SRA) (OEA =>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if (!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IEA=>DOUTA)=(0.2,0.2);
if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DOUTA)=(0.2,0.2);      if ( MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IEA=>DOUTA)=(0.2,0.2);

if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]&!SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (DINB=>IOB)=(0.2,0.2);  if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]& SRB) (OEB =>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if (!MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]& MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]&!MCB[2]& MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]& MCB[2]&!MCB[1]&!MCB[0]) (IEB=>DOUTB)=(0.2,0.2);
if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IOB=>DOUTB)=(0.2,0.2);      if ( MCB[3]& MCB[2]&!MCB[1]& MCB[0]) (IEB=>DOUTB)=(0.2,0.2);

if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOA)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTX=>IOB)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOA)=(0.2,0.2,0.2,0.2,0.2,0.2);  if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFTXEN=>IOB)=(0.2,0.2,0.2,0.2,0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);            if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (IOA=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]&!MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]&!MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]&!MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);
if ( DFEN&!MCA[3]& MCA[2]& MCA[1]& MCA[0]) (DFRXEN=>DFRX)=(0.2,0.2);

endspecify endmodule
