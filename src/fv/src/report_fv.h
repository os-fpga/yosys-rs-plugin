#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <regex>
#include <vector>
#include <map>

using namespace std;

string hour_min_sec_convrt(int seconds);

void display_hashes(ofstream& file,int& stop);

int calc_speration_col2(std::vector<string>& golden_name,std::vector<string>& revised_name);

int calc_speration_col3(std::vector<string>& status);

void add_table_row(std::vector<string> stage,std::vector<string> golden_name,std::vector<string> revised_name,std::vector<string> status,std::vector<string> tool,string& _synth_fv_,vector<int>ttime);

// Driver Code
void write_report(string& top, string& _synth_fv_);

void gen_report(map<string, tuple<string,string,string,string,string,string,int>>fv_results);