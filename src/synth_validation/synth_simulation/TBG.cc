#include "TBG.h"
//Parsing Port information from port_info.json file

vector<string> _inputs_;
vector<string> _outputs_;

string  tb_body(string port_info,vector<string> &inputs_,  vector<string> &outputs_){

//    Json::Value port;
   ifstream port_file(port_info);
   json port = json::parse(port_file);
   int n=0;

   string name_port;
   string tb_body = "";
   string port_name = "module rs_tb_"+port[0]["topModule"].get<string>()+";\n\n";
   string instance_ref = "\t"+port[0]["topModule"].get<string>()+" golden (\n";
   string instance_imp = "\t"+port[0]["topModule"].get<string>()+"_post_synth revised (\n";

   
   for (auto x: port[0]["ports"]){
      n++;
      name_port = x["name"].get<string>();
      if (x["direction"] == "Input"){
         string inter = to_string(x["range"]["msb"].get<int>());
         port_name = port_name+"\treg ["+ to_string(x["range"]["msb"].get<int>())+":"+to_string(x["range"]["lsb"].get<int>())+"] "+ name_port+";\n";
         instance_ref = instance_ref + "\t\t."+name_port+"("+name_port+"),\n";
         instance_imp = instance_imp + "\t\t."+name_port+"("+name_port+"),\n";
         inputs_.push_back(name_port);
        
      }
      else if (x["direction"] == "Output"){
         name_port = name_port;
         port_name = port_name+"\twire ["+ to_string(x["range"]["msb"].get<int>())+":"+to_string(x["range"]["lsb"].get<int>())+"] "+ name_port+", "+name_port+"_net;\n";
         instance_ref = instance_ref + "\t\t."+name_port+"("+name_port+"),\n";
         instance_imp = instance_imp + "\t\t."+name_port+"("+name_port+"_net),\n";
         outputs_.push_back(name_port);
      } 
   }
   instance_ref.resize(instance_ref.size()-2);
   instance_imp.resize(instance_imp.size()-2);
   instance_ref =instance_ref+ "\n\t);\n";
   instance_imp =instance_imp+ "\n\t);\n";
   tb_body = port_name +"\n"+instance_ref + "\n" +instance_imp;
   return tb_body;
}

//Module head 
void module_head(std::ofstream &module, string& port_inf)
{
    module << "//_____________  _________      ___________    ___________   __      __ \n";
    module << "//     ||        ||       \\    /               ||            ||\\     || \n";
    module << "//     ||        ||        |  ||               ||            || \\    || \n";
    module << "//     ||        ||_______/   ||   _______     ||________    ||  \\   || \n";
    module << "//     ||        ||       \\   ||          \\    ||            ||   \\  || \n";
    module << "//     ||        ||        |  ||          ||   ||            ||    \\ || \n";
    module << "//     ||        ||_______/    \\__________/    ||__________  ||     \\|| \n\n\n";
 
    string rs_tb_body;

    rs_tb_body = tb_body(port_inf,_inputs_,_outputs_);
    module << rs_tb_body<<endl;

    module << "integer mismatch =0;"<<endl;
}

//Clock_initialization
vector<string> print_clk_gen(std::ofstream& clock_gen,string& clock_ports){
    string delim=",";
    vector<string> clocks;
    size_t pos;
    while ((pos = clock_ports.find(",")) != std::string::npos)
    {
        clocks.push_back(clock_ports.substr(0, pos));
        clock_ports.erase(0, pos + delim.length());
        
    }
    clocks.push_back(clock_ports);
    
    for (auto &element:clocks){
    if (element=="null"){
        clock_gen << "//Clock Not Found"<<endl;
        break;
    }
    else
    {
        clock_gen << "\n\talways #10 " + element + " =  ~" + element +";";
    }
    }
    return clocks;

}

// Reset Initialization
vector<string> print_rst_gen(std::ofstream& file, vector <string> inputs,string& reset_ports,string& reset_value){

    string delim=",";
    vector<string> resets;
    size_t pos;
    while ((pos = reset_ports.find(",")) != std::string::npos)
    {
        resets.push_back(reset_ports.substr(0, pos));
        reset_ports.erase(0, pos + delim.length());
        
    }
    resets.push_back(reset_ports);
    for (auto rst:resets){
        if (rst== "null"){
            file << "//Reset port Not Found"<<endl;
        }
       else {
        if (reset_value=="1")
        file << "\n\n\tinitial begin\n\t\t" + rst + "= 1'b1; \n\t\t#20 " + rst + " = 1'b0; \n\tend\n\n" <<endl;
        else if (reset_value=="0")
        file << "\n\n\tinitial begin\n\t\t" + rst + "= 1'b0; \n\t\t#20 " + rst + " = 1'b1; \n\tend\n\n" <<endl;
        }
    }
    return resets;
}


//Parameter Initialization with 0
string  ini_param(string port_info, vector<string> &clks_val, vector<string> &rst_val){
   ifstream port_file(port_info);
   json ports = json::parse(port_file);
   int n=0;
   
   string nam_port;
   string initial_param = "";
   string port_nam ;
   string ini_nam;
   string end_nam; 
   string comparator;
   string display_stim;

   for (auto x: ports[0]["ports"]){
       n++;
       nam_port = x["name"].get<string>();
        if (x["direction"] == "Input"){
            if(!(count(clks_val.begin(), clks_val.end(),nam_port)) && !(count(rst_val.begin(), rst_val.end(),nam_port))){
                int inte = (x["range"]["msb"].get<int>())+1;
                ini_nam = "\tinitial begin \n ";
                port_nam = port_nam + nam_port + "="+to_string(inte)+"'h0;\n\t\t";
                comparator = "display_stimulus();\n\t\t";
                display_stim = "compare();\n";
                end_nam = "\n\tend\n";

            }
        }
    
     } 

  return  initial_param =  ini_nam +  "\t\t" + port_nam + comparator + display_stim + end_nam + "\n";

  
}
//
//
////Random Parameter Initialization 
string  ini_rand(string port_info, vector<string> &clks_val, vector<string> &rst_val){

    ifstream port_file(port_info);
    json ports = json::parse(port_file);

    int n=0;

    string nam_port;
    string ini_rand = "";
    string ini_random ;
    string ini_nam;
    string end_nam;
    string comparator;
    string display_stim;
  
    for (auto x: ports[0]["ports"]){
        n++;
        nam_port = x["name"].get<string>();
        if (x["direction"] == "Input"){
        // string inte = to_string((x["range"]["msb"].get<int>())+1);
            if(!(count(clks_val.begin(), clks_val.end(),nam_port)) && !(count(rst_val.begin(), rst_val.end(),nam_port))){
                ini_nam = "\tinitial begin \n\t\trepeat(20) begin \n\t#20 ";
                ini_random = ini_random + nam_port + " = $random;\n\t\t\t";
                comparator = "display_stimulus();\n\t\t";
                display_stim = "\tcompare();\n";
                end_nam = "\n\t\tend\n\tend \n";
            }
        }
    } 

    ini_rand = ini_nam +"\t" + ini_random + comparator + display_stim + end_nam + "\n";
    return ini_rand;
}


void compare(std::ofstream &compare_task, vector <string> _output_ports_){
    compare_task << "\ttask compare();\n\t\t$display (\"*************comparing*************\");\n\t\t begin\n";
    for (auto port:_output_ports_){
        compare_task <<  "\t\tif (" + port + " !== " + port + "_net" +")begin\n";
        compare_task << "\t\t\t$display(\"Data Mismatch.Golden RTL: %0d, Netlist:%0d, Time:%0t\"," + port + "," + port + "_net, $time);\n";
        compare_task << "\t\t\tmismatch = mismatch+1;"<<endl;
        compare_task << "\t\tend" <<endl;
        compare_task <<  "\t\telse begin\n";
        compare_task << "\t\t\t$display(\"Data match.Golden RTL: %0d, Netlist:%0d, Time:%0t\"," + port + "," + port + "_net, $time);\n";
        compare_task << "\t\tend" <<endl;
    }
    compare_task << "\t\tend \n \tendtask\n\n"<<endl;
}


void display(std::ofstream &display_stimulus, vector <string> _input_ports_){
    display_stimulus << "\ttask display_stimulus();\n\t\t";
    string disp_port = "$display($time, \"Test stimulus is: ";
    string inp_port = "";
    for (auto port:_input_ports_){
        disp_port = disp_port + port + " = %0d" + " ";
        inp_port =inp_port + "," + port + " ";
        
    }
    // instance_ref.resize(instance_ref.size()-2);
    display_stimulus <<disp_port + "\" " + inp_port + ");\n";  
    display_stimulus << "\tendtask\n\n"<<endl;
}

void dump(std::ofstream &dump_vcd)
{
    dump_vcd << "\tinitial begin \n \t\t$dumpfile(\"tb.vcd\"); \n\t\t$dumpvars;\n\tend" <<endl;
}

void ending_module(std::ofstream &module_end)
{
    module_end << "\n endmodule \n";
  

}


void wite_tb(string& synth_dir,string& clock_ports,string& reset_port,string& reset_value){

    ifstream RTL, post_synth, port_info;
    ofstream tbgen;
    string port_inf = synth_dir+"/port_info.json";
    port_info.open(port_inf);
    tbgen.open(synth_dir+"/tb.sv", ios::out);

    module_head(tbgen,port_inf);
    vector<string> clks_val = print_clk_gen(tbgen,clock_ports);
    vector<string> rst_val = print_rst_gen(tbgen,_inputs_,reset_port,reset_value);
    string rs_ini = ini_param(port_inf,clks_val,rst_val);
    tbgen << rs_ini <<endl;
    string rs_rand = ini_rand(port_inf,clks_val,rst_val);
    tbgen << rs_rand <<endl;
    display(tbgen, _inputs_);
    compare(tbgen, _outputs_);
    dump(tbgen);
    ending_module(tbgen);

    RTL.close();
    // post_synth.close();
    port_info.close();
    tbgen.close();

}

// int main(){
//     string sim_dir = "/nfs_scratch/scratch/FV/awais/Synthesis_FV_Poject/test/";
//     string clock_ports="wb_clk_i"; // clocks are provided separated by commas

//     string reset_port= "arst_i,wb_rst_i";
//     string reset_value= "0,0"; // active low/high
//     cout<<"Befor generating testbench for synth_rs"<<endl;
//     wite_tb(sim_dir,clock_ports,reset_port,reset_value);

//     return 0;
// }
 
