 

#include <iostream>
#include <fstream>
#include <string>
#include <regex>
using namespace std;

// Driver Code
void writing (std::ifstream& file1,std::ofstream& sim_model,std::string sline, std::string eline)
{
bool check;
std::string line;

//sim_model.open ("sim_models.v",ios::app);

while (getline(file1,line))
{
	
	if (line==sline)
	{
		check=true;
	}
	if (check)
	{
		if (regex_match (line, regex("(.*initial Q = INIT;)") ))
		sim_model <<"//initial Q = INIT;\n";
		else
		sim_model << line+"\n";

        if (line==eline)
        {
        check=false;
        break;
        }
	}	
}
}

int gen_sim_model()
{
std::ifstream file1;
std::ifstream file2;
std::ofstream sim_model; 
file2.open ("/nfs_scratch/scratch/FV/ayyaz/project_fv_synth/yosys_verific_rs/yosys-rs-plugin/genesis/cells_sim.v");
file1.open ("/nfs_scratch/scratch/FV/ayyaz/project_fv_synth/yosys_verific_rs/yosys/share/simlib.v");
remove("sim_models.v");
sim_model.open ("sim_models.v",ios::app);
if (file1.fail())
{
	std::cout<<"File1 failed to open"<<endl;
	return 1;
}

if (file2.fail())
{
	std::cout<<"File2 failed to open"<<endl;
	return 1;
}
writing (file1,sim_model,"module \\$bmux (A, S, Y);", "endmodule");
writing (file1,sim_model,"module \\$lut (A, Y);", "endmodule");
writing (file2,sim_model,"module dffsre(", "endmodule");
writing (file2,sim_model,"module dffnsre(", "endmodule");
writing (file2,sim_model,"module latchsre (", "endmodule");
writing (file2,sim_model,"module latchnsre (", "endmodule");
writing (file2,sim_model,"module sh_dff(", "endmodule");
writing (file2,sim_model,"module adder_carry(", "endmodule");
file1.close();
file2.close();
sim_model.close();
return 1;	
}
 
