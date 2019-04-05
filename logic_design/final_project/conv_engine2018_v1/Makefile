DEBUG = 0
SRC = top.v load_bmp.v sram.v filter.v
BAK = *.bak
LOG = *.log *.key *.fsdb img_gray*.txt out_log.txt *_output.bmp
INCA_libs = INCA_libs

all:
	ncverilog +debug=${DEBUG} ${SRC} +access+r

clean:
	-rm -f ${BAK} ${LOG}
	-rm -rf ${INCA_libs}
