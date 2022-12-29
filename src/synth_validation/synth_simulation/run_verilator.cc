#include <iostream>
#include <stdexcept>
#include <stdio.h>
#include <string>
#include "TBG.h"
using namespace std;

string exec(string command) {
   char buffer[128];
   string result = "";

   // Open pipe to file
   FILE* pipe = popen(command.c_str(), "r");
   if (!pipe) {
      return "popen failed!";
   }

   // read till end of process:
   while (!feof(pipe)) {

      // use buffer to read and add to the result
      if (fgets(buffer, 128, pipe) != NULL)
         result += buffer;
   }

   pclose(pipe);
   return result;
}
void update_netlist_name(string post_synth_net_dir,string &top_module){
   string original_name="module "+top_module;
   string replaced_name="module "+top_module+"_post_synth";
   string command="sed -i 's/"+original_name+"/"+replaced_name+"/' "+post_synth_net_dir+"/sim_dir/post_synthesis.v";
   //cout<<"Replacing post synthesis netlist module name for verilator: "<<command<<endl;
   string ls = exec(command); 
   //cout <<ls<<endl; 
}

void launching_varilator(string &rtl_files,string &cells_sim,string post_synth_net_dir,string &top_module) {
   update_netlist_name(post_synth_net_dir,top_module);
   string tb_dir=post_synth_net_dir+"/sim_dir/tb.v";
   string tb_cpp_dir=post_synth_net_dir+"/sim_dir/tb.cpp"; 
   string obj_dir=post_synth_net_dir+"/obj_dir";
   string verilator_init= "verilator -Wno-fatal -Wno-BLKANDNBLK -sc -exe "+tb_dir+" "+tb_cpp_dir+" --timing --timescale 1ps/1ps --trace ";
   string post_synthesis_verilog=" -v "+post_synth_net_dir+"/sim_dir/post_synthesis.v -y +libext+.v+.sv"; 
   string verilator_command2=" && make -j -C "+obj_dir+" -f Vtb.mk Vtb";
   string verilator_command3=" && "+obj_dir+"/Vtb 2>&1 | tee post_synth_sim.log";
   string command=verilator_init+rtl_files+cells_sim+post_synthesis_verilog+verilator_command2+verilator_command3;
   cout<<"Launching Verilator for synth_rs"<<endl;
   string ls = exec(command);
   cout <<ls<<endl;
   if (ls=="sh: verilator: command not found")
    cout <<ls<<endl;
   else {
    ls = exec("vcd2fst tb.vcd tb.fst --compress");
    cout <<"vcd generated: "<<endl;
   }
    
}