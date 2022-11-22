mkdir pmgen
wget -nc -O pmgen.py https://raw.githubusercontent.com/YosysHQ/yosys/master/passes/pmgen/pmgen.py

python3 pmgen.py -o pmgen/rs-dsp-pm.h -p rs_dsp rs_dsp.pmg
python3 pmgen.py -o pmgen/rs-dsp-macc.h -p rs_dsp_macc rs-dsp-macc.pmg
python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-write.h -p rs_bram_asymmetric_wider_write rs-bram-asymmetric-wider-write.pmg
python3 pmgen.py -o pmgen/rs-bram-asymmetric-wider-read.h -p rs_bram_asymmetric_wider_read rs-bram-asymmetric-wider-read.pmg

