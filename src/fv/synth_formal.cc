#include "synth_formal.h"

using namespace std; 
// #include <filesystem>
// namespace fs = std::filesystem;




void process_stage(struct fv_args *stage_arg){
    // struct fv_args *stage_arg = (struct fv_args *)fvarg;
    // synth_configuration configuration;
    std::cout<<"DSP Inference "<<*stage_arg->dsp_inf<<std::endl;

    int test_convd = *stage_arg->dsp_inf?1:0;
    int test_convb = *stage_arg->bram_inf?1:0;
    int test_convr = *stage_arg->retiming?1:0;
    int out = (test_convd << 2) | (test_convb<<1) | test_convr;
    
    std::cout<<"Case: "<<out<<std::endl;

    switch(out){
        case(7):{
            std::cout<<"Case 1"<<std::endl;
            break;
        }
        case(1):
            std::cout<<"Case 2"<<std::endl;
            break;
        case(2):
            std::cout<<"Case 3"<<std::endl;
            break;
        case(3):
            std::cout<<"Case 4"<<std::endl;
            break;
        case(4):
            std::cout<<"Case 5"<<std::endl;
            break;
        case(5):
            std::cout<<"Case 6"<<std::endl;
            break;
        case(6):
            std::cout<<"Case 7"<<std::endl;
            break;
        case(0):
            std::cout<<"Case 8"<<std::endl;
            break;
        default:
            std::cout<<"DSP inference is turned default"<<std::endl;
            break;
    }
}

void *run_fv(void* flow) {
    // pthread_t file_t;
    struct fv_args *fvargs = (struct fv_args *)flow;
    std::string ref_net = *fvargs->ref_net;
    process_stage(fvargs);
    int fV_timeout = *fvargs->fv_timeout;

    std::cout<<"Synthesis Status "<<fvargs->synth_status<<std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(5)); 
    std::cout<<"Golden Netlist "<<ref_net<<std::endl;
    std::cout<<"Formal Veriication Timeout "<<fV_timeout<<std::endl;
    std::cout<<"Synthesis Status "<<fvargs->synth_status<<std::endl;
    std::cout<<"DSP Inference "<<*fvargs->dsp_inf<<std::endl;

    pthread_exit(NULL);
    return NULL;
}