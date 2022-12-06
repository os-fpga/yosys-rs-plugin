#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <regex>
#include <vector>
using namespace std;

void display_hashes(ofstream& file,int& stop)
{
    for (int i=0 ; i<stop ;i++)
    file<<"-";
    file<<"\n";
}

int calc_speration_col2(std::vector<string>& golden_name,std::vector<string>& revised_name){
    int max_spacing=0;
    std::vector<string> comp;
    for (auto i=0;i!=golden_name.size(); ++i)
        comp.push_back(golden_name[i]+" Vs "+revised_name[i]);
    for (auto j=0;j!=comp.size();++j)
    {
        if (comp[j].size()>max_spacing)
            max_spacing=comp[j].size();
    }
    return(max_spacing);
}
int calc_speration_col3(std::vector<string>& status){
    int max_spacing=0;
    for (auto j=0;j!=status.size();++j)
    {
        if (status[j].size()>max_spacing)
            max_spacing=status[j].size();
    }
    return(max_spacing);
}

void add_table_row(std::vector<string> stage,std::vector<string> golden_name,std::vector<string> revised_name,std::vector<string> status,std::vector<string> tool,ofstream& file){
    const char space    = ' ';
    const int width_col1=8;
    int stop;
    int spacing_col2=calc_speration_col2(golden_name,revised_name); 
    int spacing_col3=calc_speration_col3(status);
    file.open ("fv_synth.log",ios::app);
    file<< "\n\n================================= Formal Verification =====================================\n\n";
    stop=11+spacing_col2+5+spacing_col3+14;
    display_hashes(file,stop);
    file<<left<<setw(11)<<' '<<"Comparison"<<setw(spacing_col2-5)<<' '<<"Verification status"<<setw(spacing_col3-14)<<' '<<"TOOL\n";
    display_hashes(file,stop);
    for (auto j=0;j!=stage.size();++j){
    file<<left<<setw(width_col1)<<stage[j]<<"|"<<setw(2)<<space<<setw(spacing_col2)<<golden_name[j]+" Vs "+revised_name[j]<<setw(2)<<space<<"|"<<setw(2)<<space<<setw(spacing_col3)<<status[j]<<setw(2)<<space<<"|"<<setw(2)<<space<<tool[j]+"\n";
    }
    file<<"\n\n============================================================================================\n\n";
    file.close();
}
// Driver Code
void write_report(string& top)
{
ifstream yosys_log_file,onespin_log;
ofstream fv_synth; 
yosys_log_file.open ("yosys_output.log");
onespin_log.open ("wrapper_KeyExpantion_results.log");
fv_synth.open ("fv_synth.log",ios::out);
fv_synth.close();
if (yosys_log_file.fail())
{
	cout<<"File failed to open"<<endl;
	return;
}

if (onespin_log.fail())
{
	cout<<"onespin_log File failed to open"<<endl;
	return;
}
std::vector<std::string> list_lines;
int stat_line,statis;
string line;
bool write=false;
fv_synth.open ("fv_synth.log",ios::app);
fv_synth <<"================================= Synthesis Utilization =================================\n\n";
/////////////////////////////////////////////////////////////////////
std::string strLine;
char buf;

yosys_log_file.seekg(0, std::ios::beg);
std::ifstream::pos_type posBeg = yosys_log_file.tellg();

yosys_log_file.seekg(-1, std::ios::end);

while (yosys_log_file.tellg() != posBeg)
{
    buf = static_cast <char>(yosys_log_file.peek());

    if (buf != '\n')
    {
        strLine += buf; //combining the charactors to make a single line string 
    }
    else
    {
        std::reverse(strLine.begin(), strLine.end());
        // Picking the intersting line.
		if (write)
		list_lines.push_back(strLine+"\n");
		if (strLine=="=== "+top+" ===")
		{
		break;
		}
		if (regex_match (strLine, regex(".*Executing OPT_CLEAN pass.*")))
		{
		write=true;
		//cout<<strLine<<endl;	
		}

        strLine.clear(); //important to clear the string
    }

    yosys_log_file.seekg(-1, std::ios::cur);
}
yosys_log_file.close();
reverse(list_lines.begin(), list_lines.end());
for (auto j = list_lines.begin(); j != list_lines.end(); ++j) 
    fv_synth<< *j;
fv_synth.close();
return;
}
int main()
{
string top="b01";
write_report(top);
ofstream fv_synth; 
std::vector<string> stage;
std::vector<string> golden_name;
std::vector<string> revised_name;
std::vector<string> status;
std::vector<string> tool;
stage.push_back("stage1");golden_name.push_back("RTL");revised_name.push_back("after_flatten");status.push_back("Verifiction Succeeded");tool.push_back("Onespin");
stage.push_back("stage2");golden_name.push_back("after_flatten");revised_name.push_back("after_fsm");status.push_back("Verifiction Succeeded");tool.push_back("Onespin");
stage.push_back("stage3");golden_name.push_back("after_fsm");revised_name.push_back("after_dsp_map4");status.push_back("Verifiction Succeeded");tool.push_back("Onespin");
stage.push_back("stage4");golden_name.push_back("after_dsp_map4");revised_name.push_back("after_opt-fast-full");status.push_back("Verifiction Failed");tool.push_back("Formality");
stage.push_back("stage5");golden_name.push_back("after_opt-fast-full");revised_name.push_back("after_dfflegalize after_dfflegalize");status.push_back("Verifiction Succeeded");tool.push_back("Onespin");
stage.push_back("stage6");golden_name.push_back("after_dfflegalize");revised_name.push_back("after_techmap_ff_map");status.push_back("Verifiction Inconclusive");tool.push_back("Onespin");
stage.push_back("stage7");golden_name.push_back("after_techmap_ff_map");revised_name.push_back("final_netlist");status.push_back("Verifiction Succeeded");tool.push_back("Onespin");
add_table_row(stage, golden_name, revised_name, status, tool,fv_synth);// writing Formal verification report table
return 0;	
}

 
