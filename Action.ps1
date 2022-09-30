mkdir pmgen
wget -nc -O pmgen.py https://raw.githubusercontent.com/YosysHQ/yosys/master/passes/pmgen/pmgen.py
ls
python3 pmgen.py -o pmgen/rs-dsp-pm.h -p rs_dsp rs_dsp.pmg
ls
python3 pmgen.py -o pmgen/rs-dsp-macc.h -p rs_dsp_macc rs-dsp-macc.pmg
ls
