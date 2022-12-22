#include "report_fv.h"
string hour_min_sec_convrt(int seconds){
    int minutes, hours;
    hours = seconds/3600;
    seconds = seconds%3600;
    minutes = seconds/60;
    seconds = seconds%60;
    string time_=to_string(hours)+":"+to_string(minutes)+":"+to_string(seconds);
    cout<<time_<<endl;
    return time_;
}
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

void add_table_row(std::vector<string> stage,std::vector<string> golden_name,std::vector<string> revised_name,std::vector<string> status,std::vector<string> tool,string& _synth_dir_, vector<int>ttime){
    ofstream file;
    const char space    = ' ';
    const int width_col1=8;
    int stop;
    int spacing_col2=calc_speration_col2(golden_name,revised_name); 
    int spacing_col3=calc_speration_col3(status);
    int spacing_col4=calc_speration_col3(tool);
    file.open (_synth_dir_+"/fv_synth.log",ios::app);
    file<< "\n\n================================= Formal Verification =====================================\n\n";
    stop=11+spacing_col2+5+spacing_col3+14+25;
    display_hashes(file,stop);
    file<<left<<setw(11)<<' '<<"Comparison"<<setw(spacing_col2-5)<<' '<<"Verification status"<<setw(spacing_col3-14)<<' '<<"TOOL"<<setw(8)<<' '<<"Time (Hr:Min:Sec)\n";
    display_hashes(file,stop);
    for (auto j=0;j!=stage.size();++j){
        file<<left<<setw(width_col1)<<stage[j]<<"|"<<setw(2)<<space<<setw(spacing_col2)<<golden_name[j]+" Vs "+revised_name[j]<<setw(2)<<space<<"|"<<setw(2)<<space<<setw(spacing_col3)<<status[j]<<setw(2)<<space<<"|"<<setw(2)<<space<<setw(spacing_col4)<<tool[j]<<"|"<<setw(5)<<space<<hour_min_sec_convrt(ttime[j])<<"\n";
    }
    file<<"\n\n============================================================================================\n\n";
    file.close();
}
// Driver Code
void write_report(string& top, string &_synth_dir_)
{
ifstream yosys_log_file,onespin_log;
ofstream fv_synth; 
yosys_log_file.open (_synth_dir_+"/yosys_output.log");
// onespin_log.open ("wrapper_KeyExpantion_results.log");
fv_synth.open (_synth_dir_+"/fv_synth.log",ios::out);
fv_synth.close();
if (yosys_log_file.fail())
{
	cout<<"File failed to open"<<endl;
	return;
}

// if (onespin_log.fail())
// {
// 	cout<<"onespin_log File failed to open"<<endl;
// 	return;
// }
std::vector<std::string> list_lines;
int stat_line,statis;
string line;
bool write=false;
fv_synth.open (_synth_dir_+"/fv_synth.log",ios::app);
fv_synth <<"================================= Synthesis Utilization =================================\n\n";
/////////////////////////////////////////////////////////////////////
std::string strLine;
char buf;

yosys_log_file.seekg(0, std::ios::beg);
std::ifstream::pos_type posBeg = yosys_log_file.tellg();

yosys_log_file.seekg(-1, std::ios::end);

while (yosys_log_file.tellg() != posBeg){
    buf = static_cast <char>(yosys_log_file.peek());

    if (buf != '\n'){
        strLine += buf; //combining the charactors to make a single line string 
    }
    else{
        std::reverse(strLine.begin(), strLine.end());
        // Picking the intersting line.
		if (write)
		    list_lines.push_back(strLine+"\n");
		if (strLine=="=== "+top+" ==="){
		    break;
		}
		if (regex_match (strLine, regex("yosys> opt_clean -purge"))){     //strLine, regex(".*Executing OPT_CLEAN pass.*")) ||
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

void gen_report(map<string, tuple<string,string,string,string,string,string,int>>fv_results){
    
    map<string, tuple<string,string,string,string,string,string>>::iterator itr;
    vector<string> stg;
    vector<string> golden_stg;
    vector<string> revised_stg;
    vector<string> status_stg;
    vector<string> tool_stg;
    vector <int> ttime;
    string _synth_dir_;
    string _stg_top_;
    int fvstats;
    bool misstat = false;
    for (auto const& key: fv_results){
        if (get<2>(key.second) == "Verification Succeeded" && fvstats != 2 && fvstats != 3){
            fvstats = 1;
        }
        else if (get<2>(key.second) == "Verification Failed"){
            fvstats = 2; 
        }
        else if (get<2>(key.second) == "Verification Inconclusive" && fvstats == 1){
            fvstats = 3;
        }
        else{
            misstat = true;
        }
        stg.push_back(key.first);
        golden_stg.push_back(get<0>(key.second));
        revised_stg.push_back(get<1>(key.second));
        status_stg.push_back(get<2>(key.second));
        tool_stg.push_back(get<3>(key.second));
        _synth_dir_ = get<4>(key.second);
        _stg_top_ = get<5>(key.second);
        ttime.push_back(get<6>(key.second));
        cout<<"Total Time: "<<get<6>(key.second)<<endl;
    }
    if (fvstats==1 && misstat) fvstats = 4;
    write_report(_stg_top_,_synth_dir_);
    add_table_row(stg, golden_stg, revised_stg, status_stg, tool_stg,_synth_dir_,ttime);
    ofstream fvrpt;
    fvrpt.open(_synth_dir_+"/fv_synth.log",ios::app);

    fvrpt<<"Formal Verification Summary:"<<endl<<
        "\n\tVerification Approach: Incremental verification"<<endl<<
        "\tVerification Status: ";
    switch (fvstats){
        case 0:
            fvrpt<<"Formal verification was not run, make sure formal verification tool's license is availble"<<endl;
            break;
        case 1:
            fvrpt<<"Both the designs are equivalent"<<endl;
            break;
        case 2:
            fvrpt<<"Both the designs are not equivalent"<<endl;
            break;
        case 3:
            fvrpt<<"Formal verification results are inconclusive"<<endl;
            break;
        default:
            fvrpt<<"Formal verification results are inconclusive"<<endl; 
            break;
    }
    fvrpt<<"\n*In case of inconclusive results or verification failure, Raptor simulation can be performed on the two designs, "<<endl;
    fvrpt<<"for this use <synth_rs -fv simulation>."<<endl;
    fvrpt.close();

}

 
