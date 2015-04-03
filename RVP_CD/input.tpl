;;Modified at 11/22/2014.
;;Changed the delay of write driver to be consistent with write_driver_inter
;;Separated energy calculation for different read and write ports. 2014/12/12.
;;The width of WLA is decided by RBLBM falling down to VDD/2. 2014/12/14.
;; Added power for col buf and CSEL driver. 2014/12/14.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; POWER-DELAY CHARACTERIZATION OF CD
;; Satya Nalam 03-28-2010

;; set simulator
simulator( 'spectre)
(envSetVal "spectre.opts" "multithread" 'string "on")
(envSetVal "spectre.opts" "nthreads" 'string "3")

;; set model lists
modelFile(
    '("<include>")
    '("<subN>")
    '("<subP>")
    '("<subPU>")
    '("<subPD>")
    '("<subPG>")
)

;; open file for writing characterization results
of = outfile("datar.txt","w")

; reduce the loops to a single iteration if only getting metrics for a particular configuration
; sweep rows at only those points that correspond to col-mux of 1,2,4 or 8.
; initialize rows to correspond to col-mux of 8 if sweeping, otherwise to specified number of rows.
char = <char>
numWords = <memsize>/<ws>
if( char == 1 then
	maxRows = 512  ;;upper limit 512 rows
	rows = 16 ;;lower limit of 16 rows
	;rowStep = (maxRows-rows)/5 ;ensure we get atleast 5 points for the row sweep
	rowStep = 2
else
	maxRows = <NR_sweep>
	rows = <NR_sweep>
	rowStep = 2
)
NRLBL = <NRLBL>
NLBL = rows/NRLBL
;; sweep rows 
;; Define two parameter "BL_sensing" and "Local_BL" to indicate the type of BL structure. Default values are "diff" for BL_sensing and "false" for Local_BL.
BL_sensing = "diff"
Local_BL = "false"
while( (rows <= maxRows)

	colMux = <colMux>
	bcType = "<bcType>"
	;; Copy appropriate READ netlist
	if( colMux ==1 then
		if( bcType=="6T" then
			cpnetlist = "cp -f ./READ/netlist_one netlist"
		)
        if( bcType=="10T2r1w_single" then
			cpnetlist = "cp -f ./READ/netlist_one_10T2r1w_single netlist"
            BL_sensing = "single"
        )
        if( bcType=="10T2r1w_diff" then
			cpnetlist = "cp -f ./READ/netlist_one_10T2r1w_diff netlist"
        )
        if( bcType=="8T1r1w_single" then
			cpnetlist = "cp -f ./READ/netlist_one_8T1r1w_single netlist"
            BL_sensing = "single"
		)
        if( bcType=="8T1r1w_single_LBL" then
          if( NLBL==2 then 
			cpnetlist = "cp -f ./READ/netlist_one_8T1r1w_single_LBL2 netlist"
            BL_sensing = "single"
            Local_BL = "true"
          else
			cpnetlist = "cp -f ./READ/netlist_one_8T1r1w_single_LBL netlist"
            BL_sensing = "single"
            Local_BL = "true"
            )
		)
        if( bcType=="8T1r1w_diff" then
			cpnetlist = "cp -f ./READ/netlist_one_8T1r1w_diff netlist"
		)
        if( bcType=="12T2r2w_diff" then
			cpnetlist = "cp -f ./READ/netlist_one_12T2r2w_diff netlist"
        )
        if( bcType=="12T2r2w_single" then
			cpnetlist = "cp -f ./READ/netlist_one_12T2r2w_single netlist"
            BL_sensing = "single"
        )
	else
		if( bcType=="6T" then
			cpnetlist = "cp -f ./READ/netlist_mult netlist"
		)
        if( bcType=="10T2r1w_single" then
			cpnetlist = "cp -f ./READ/netlist_mult_10T2r1w_single netlist"
            BL_sensing = "single"
		)
        if( bcType=="10T2r1w_diff" then
			cpnetlist = "cp -f ./READ/netlist_mult_10T2r1w_diff netlist"
        )
        if( bcType=="8T1r1w_single" then
			cpnetlist = "cp -f ./READ/netlist_mult_8T1r1w_single netlist"
            BL_sensing = "single"
		)
        if( bcType=="8T1r1w_single_LBL" then
          if( NLBL==2 then 
			cpnetlist = "cp -f ./READ/netlist_mult_8T1r1w_single_LBL2 netlist"
            BL_sensing = "single"
            Local_BL = "true"
          else
			cpnetlist = "cp -f ./READ/netlist_mult_8T1r1w_single_LBL netlist"
            BL_sensing = "single"
            Local_BL = "true"
            )
		)
        if( bcType=="8T1r1w_diff" then
			cpnetlist = "cp -f ./READ/netlist_mult_8T1r1w_diff netlist"
		)
        if( bcType=="12T2r2w_diff" then
			cpnetlist = "cp -f ./READ/netlist_mult_12T2r2w_diff netlist"
        )
        if( bcType=="12T2r2w_single" then
			cpnetlist = "cp -f ./READ/netlist_mult_12T2r2w_single netlist"
            BL_sensing = "single"
        )
	)
	sh( cpnetlist )
	design(  "./netlist")
	resultsDir("./OUTR")

	VDD = <pvdd>
	desVar(	  "wpu" <wpu>	)
	desVar(	  "lpu" <lpu>	)
	desVar(	  "wpd" <wpd>	)
	desVar(	  "lpd" <lpd>	)
	desVar(	  "wpg" <wpg>	)
	desVar(	  "lpg" <lpg>	)
	desVar( "WLOffset" <WLOffset> )
	desVar( "wrd1" <wrd1> )
	desVar( "lrd1" <lrd1> )
	desVar( "wrdpg" <wrdpg>   )
	desVar( "lrdpg" <lrdpg>   )
	desVar(   "numBanks" <numBanks>)
	desVar("ldef" <ldef>)
	desVar("wdef" <wdef>)
	desVar("tper" <tper>)
	desVar("trf" <trf>)
	desVar("tdly" <tdly>)
	desVar("cbl" <cbl>)
	desVar("cwl" <cwl>)
	desVar("cg" <cg>)
	desVar("ws" <ws>)
	desVar("wnio" 10*<wdef>) 
	desVar("pvdd" VDD    )

	temp( <temp> )
	option( 'reltol <reltol> 'gmin <gmin>)
	desVar("NR" rows)
	desVar("colMux" colMux-1) ;unused if col-mux is 1
    desVar( "NRLBL" NRLBL)
    desVar( "NLBL" NLBL)

	desVar("twl" <tper>/1.5)
	analysis('tran ?start 0 ?stop 1.1*<tper> ?step 0.01n ?strobeperiod 0.001n ?errpreset 'moderate)
	run()

	; time required for given bitline differential, tper should be sufficiently large
	selectResults('tran)
	if( bcType=="6T" then
		dly_bldis = cross(v("BL") VDD-<BL_DIFF> 1 'falling) - cross(v("WLA") VDD/2 1 'rising)
	else
    if( bcType=="10T2r1w_diff" then
		dly_bldis = cross(v("BL") VDD-<BL_DIFF> 1 'falling) - cross(v("WLA") VDD/2 1 'rising)
    else
    if( bcType=="8T1r1w_diff" then
		dly_bldis = cross(v("BL") VDD-<BL_DIFF> 1 'falling) - cross(v("WLA") VDD/2 1 'rising)
    else
    if( bcType=="12T2r2w_diff" then
		dly_bldis = cross(v("BL") VDD-<BL_DIFF> 1 'falling) - cross(v("WLA") VDD/2 1 'rising)
    else
		dly_bldis = cross(v("RBLBM") VDD/2 1 'falling) - cross(v("WLA") VDD/2 1 'rising)
	))))

	; run analysis with wl width just enough for given bitline differential
	desVar("twl" dly_bldis)
	analysis('tran ?start 0 ?stop 1.3*<tper> ?step 0.01n ?strobeperiod 0.001n ?errpreset 'moderate)
	run()

	;; measure power - all columns discharge doing either dummy read or full read.
	selectResults('tran)


    ;;Only valid when colMux is larger than 1. Modified at 10/30/2014.
	;;avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+average(getData("IPCHD:pwr"))
    ;;Modified the equation of PCH buf energy by adding a part for IPCH_buf.2015/1/17.
	if( colMux>1 then
      if( bcType=="8T1r1w_single_LBL" then
        if(NLBL==2 then
        avg_pwr_hs= average(getData("ICOLD.ICOL_LBL.ICDA:pwr"))+ average(getData("ICOLD.ICOL_LBL2.ICDA:pwr"))
        avg_pwrbc_hs= average(getData("ICOLD.ICOL_LBL.IBCA:pwr")) + average(getData("ICOLD.ICOL_LBL2.IBCA:pwr"))
       else
        avg_pwr_hs= average(getData("ICOLD.ICOL_LBL.ICDA:pwr"))+ average(getData("ICOLD.ICOL_LBLD.ICDA:pwr"))+ average(getData("ICOLD.ICOL_LBL2.ICDA:pwr"))
        avg_pwrbc_hs= average(getData("ICOLD.ICOL_LBL.IBCA:pwr"))+ average(getData("ICOLD.ICOL_LBLD.IBCA:pwr")) + average(getData("ICOLD.ICOL_LBL2.IBCA:pwr"))
        )
      else
		avg_pwr_hs = average(getData("ICOLD.ICDA:pwr"))
		avg_pwrbc_hs = average(getData("ICOLD.IBCA:pwr"))
      )
	else
		avg_pwr_hs = 0
		avg_pwrbc_hs = 0
	)
	dly_inter_r=cross(v("PCH") VDD/2 1 'rising) - cross(v("PCH_IN") VDD/2 1 'rising)

    
    if( bcType=="6T" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("BL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*avg_pwr_pch_buf
    );; endif 6T
    if( bcType=="8T1r1w_diff" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("BL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*avg_pwr_pch_buf
    );; endif 8T
    if( bcType=="10T2r1w_diff" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("BL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*avg_pwr_pch_buf
    );; endif 10T
    ;; Added power for col buf and CSEL driver. 2014/12/14.
    if( bcType=="8T1r1w_single" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("RBL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
    avg_pwr_colbuf=  average(getData("ICOL1_buf:pwr"))
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
    avg_csel_inter=average(getData("ICSEL:pwr"))+average(getData("ICSELB:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs+avg_pwr_colbuf)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*(avg_pwr_pch_buf+avg_csel_inter)
    );; endif 8T
    ;; energy is multiplied by 2 for 2 read ports.
    if( bcType=="10T2r1w_single" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("RBL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
    avg_pwr_colbuf=  average(getData("ICOL1_buf:pwr"))
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
    avg_csel_inter=average(getData("ICSEL:pwr"))+average(getData("ICSELB:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs+avg_pwr_colbuf)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*(avg_pwr_pch_buf+avg_csel_inter)
    );; endif 10T
    if( bcType=="12T2r2w_diff" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("BL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*avg_pwr_pch_buf
    );; endif 12T
    if( bcType=="12T2r2w_single" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_r=cross(v("RBL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	avg_pwr_r = average(getData("ICOL1.ICDA:pwr")) 
    avg_pwr_colbuf=  average(getData("ICOL1_buf:pwr"))
	avg_pwrbc_r = average(getData("ICOL1.IBCA:pwr"))
    avg_csel_inter=average(getData("ICSEL:pwr"))+average(getData("ICSELB:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs+avg_pwr_colbuf)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*(avg_pwr_pch_buf+avg_csel_inter)
    );; endif 12T
    if( bcType=="8T1r1w_single_LBL" then
	    avg_pwr_pch_buf= average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
		dly_pch_lbl=cross(v("ICOL1.ICOL_LBL.RBL_LBL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
		dly_pch_gbl=cross(v("RBL_GBL") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
		dly_pch_r=max(dly_pch_gbl,dly_pch_lbl)
        if(NLBL==2 then
        avg_pwr_r= average(getData("ICOL1.ICOL_LBL.ICDA:pwr"))+ average(getData("ICOL1.ICOL_LBL2.ICDA:pwr"))
        avg_pwrbc_r= average(getData("ICOL1.ICOL_LBL.IBCA:pwr"))+ average(getData("ICOL1.ICOL_LBL2.IBCA:pwr"))
        else
        avg_pwr_r= average(getData("ICOL1.ICOL_LBL.ICDA:pwr"))+ average(getData("ICOL1.ICOL_LBLD.ICDA:pwr"))+ average(getData("ICOL1.ICOL_LBL2.ICDA:pwr"))
        avg_pwrbc_r= average(getData("ICOL1.ICOL_LBL.IBCA:pwr"))+ average(getData("ICOL1.ICOL_LBLD.IBCA:pwr"))+ average(getData("ICOL1.ICOL_LBL2.IBCA:pwr"))
        )
    avg_pwr_colbuf=  average(getData("ICOL1_buf:pwr"))+ average(getData("IGBL_SEL:pwr"))
    avg_csel_inter=average(getData("ICSELB:pwr"))
	energycd_r = <ws>*(avg_pwr_r+avg_pwr_hs+avg_pwr_colbuf)*1.3*<tper>
	energybc_r = <ws>*(avg_pwrbc_r+avg_pwrbc_hs)*1.3*<tper>
	energy_inter_r=1.3*<tper>*(avg_pwr_pch_buf+avg_csel_inter)
    );; endif 8T

	;; write data to file
	fprintf(of,"%d\t%d\t%d\t%e\t%e\t%e\t%e\t%e\t%e\n", <numBanks>, rows, colMux, dly_bldis, dly_pch_r, energycd_r, energybc_r, energy_inter_r,dly_inter_r)
	rows = rows*rowStep
	drain(of)
)
close(of)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Write calculations

;; open file for writing characterization results
of = outfile("dataw.txt","w")

;reinitialize rows 
if( char == 1 then
	rows = 16
else
	rows = <NR_sweep>
)

;; sweep rows
while( (rows <= maxRows)

	colMux = <colMux>
	;; Copy appropriate WRITE netlist
	if( colMux ==1 then
		if( bcType=="6T" then
		cpnetlist = "cp -f ./WRITE/netlist_one netlist"
		)
        if( bcType=="10T2r1w_single" then
			cpnetlist = "cp -f ./WRITE/netlist_one_10T2r1w_single netlist"
        )
        if( bcType=="8T1r1w_single" then
			cpnetlist = "cp -f ./WRITE/netlist_one_8T1r1w_single netlist"
        )
        if( bcType=="8T1r1w_diff" then
			cpnetlist = "cp -f ./WRITE/netlist_one_8T1r1w_diff netlist"
        )
        if( bcType=="8T1r1w_single_LBL" then
			cpnetlist = "cp -f ./WRITE/netlist_one_8T1r1w_single_LBL netlist"
		)
        if( bcType=="10T2r1w_diff" then
			cpnetlist = "cp -f ./WRITE/netlist_one_10T2r1w_diff netlist"
        )
        if( bcType=="12T2r2w_diff" then
			cpnetlist = "cp -f ./WRITE/netlist_one_12T2r2w_diff netlist"
        )
        if( bcType=="12T2r2w_single" then
			cpnetlist = "cp -f ./WRITE/netlist_one_12T2r2w_single netlist"
        )
	else
		if( bcType=="6T" then
		cpnetlist = "cp -f ./WRITE/netlist_mult netlist"
		)
        if( bcType=="10T2r1w_single" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_10T2r1w_single netlist"
        )
        if( bcType=="8T1r1w_single" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_8T1r1w_single netlist"
        )
        if( bcType=="8T1r1w_diff" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_8T1r1w_diff netlist"
        )
        if( bcType=="8T1r1w_single_LBL" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_8T1r1w_single_LBL netlist"
		)
        if( bcType=="10T2r1w_diff" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_10T2r1w_diff netlist"
        )
        if( bcType=="12T2r2w_diff" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_12T2r2w_diff netlist"
        )
        if( bcType=="12T2r2w_single" then
			cpnetlist = "cp -f ./WRITE/netlist_mult_12T2r2w_single netlist"
        )
	)
	sh( cpnetlist )
	design(  "./netlist")

	resultsDir("./OUTW")

	VDD = <pvdd>
	desVar(	  "wpu" <wpu>	)
	desVar(	  "lpu" <lpu>	)
	desVar(	  "wpd" <wpd>	)
	desVar(	  "lpd" <lpd>	)
	desVar(	  "wpg" <wpg>	)
	desVar(	  "lpg" <lpg>	)

	;PD width of IO driver chosen arbitrarily as it doesn't affect CD measurements mostly - assuming its contribution to cap is small compared to all other bitline cap components.
	desVar("ldef" <ldef>)
	desVar("wdef" <wdef>)
	desVar( "wrd1" <wrd1> )
	desVar( "lrd1" <lrd1> )
	desVar( "wrdpg" <wrdpg>   )
	desVar( "lrdpg" <lrdpg>   )
	desVar("tper" <tper>)
	desVar("trf" <trf>)
	desVar( "WLOffset" <WLOffset> )
	desVar("twl" <tper>/6)
	desVar("tdly" <tdly>)
	desVar("cbl" <cbl>)
	desVar("NR" rows)
	desVar("colMux" colMux-1)
	desVar("pvdd" VDD    )
	desVar("cwl" <cwl>)
	desVar("cg" <cg>)
	desVar("ws" <ws>)
	desVar("numBanks" <numBanks>)
    desVar( "NRLBL" NRLBL)
    desVar( "NLBL" NLBL)
	temp( <temp> )
	option( 'reltol <reltol> 'gmin <gmin>)

	analysis('tran ?start 0 ?stop 1.3*<tper> ?step 0.01n ?strobeperiod 0.001n ?errpreset 'moderate)
	run()
	selectResult('tran)

	;; measure delays
	;; calculate bitcell flip energy	
    if(Local_BL == "true" then
	avg_pwrbc_w = average(getData("ICOL1.ICOL_LBL.IBCA:pwr"))
	dly_bcwr = cross((v("ICOL1.ICOL_LBL.IBCA.Q")-v("ICOL1.ICOL_LBL.IBCA.QB")) .001 1 'rising) - cross(v("WLA") VDD/2 1 'rising)
    else
	avg_pwrbc_w = average(getData("ICOL1.IBCA:pwr"))
	; Bitcell flip delay
	;;dly_bcwr = cross(v("ICOL1.IBCA.Q") VDD/2 1 'rising) - cross(v("WLA") VDD/2 1 'rising)
    ;;Use the time when Q=QB as the critiria of data flip. Modified at 10/28/2014.
	dly_bcwr = cross((v("ICOL1.IBCA.Q")-v("ICOL1.IBCA.QB")) .001 1 'rising) - cross(v("WLA") VDD/2 1 'rising)
    )
	; run analysis with enough WL pulse to just write, to prevent half-selected cells swinging full rail
	desVar("twl" dly_bcwr)
	analysis('tran ?start 0 ?stop 1.3*<tper> ?step 0.01n ?strobeperiod 0.001n ?errpreset 'moderate)
	run()
	selectResult('tran)
	
    if(Local_BL == "true" then
	delay_inter_w =cross(v("WEN") VDD*.05 1 'rising) - cross(v("WEN_IN") VDD/2 1 'rising)
    dly_lbl_sel_int = cross(v("ICOL1.ICOL_LBL.ICDA.LBL_SELB") VDD/2 1 'rising) - cross(v("LBL_SEL_IN") VDD/2 1 'rising)
    dly_gbl_w = cross(v("GBLB") VDD/2 1 'falling) - cross(v("WEN") VDD*.05 1 'rising)
    ;; The delay of data preparation should be the larger one between gbl being ready and lbl_sel being ready.
    dly_data_prep = max(delay_inter_w + dly_gbl_w, dly_lbl_sel_int)
    ;; The delay of write driver should start from WEN being ready to LBLB being ready.
    dly_writeDriver = cross(v("ICOL1.ICOL_LBL.LBLB") VDD*.05 1 'falling) - cross(v("LBL_SEL_IN") VDD/2 1 'rising)- delay_inter_w
    ;; The precharge delay should be the larger one between lbl and gbl
    dly_lbl_pch = cross(v("ICOL1.ICOL_LBL.LBLB") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling)
	dly_gbl_pch = cross(v("GBLB") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling) 
    dly_bl_pch = max(dly_lbl_pch,dly_gbl_pch)
    ;; measure power
	avg_pwr_writeDriver = average(getData("IWRD:pwr"))+average(getData("IWRDB:pwr"))
	avg_pwr_int_w=average(getData("IWEN:pwr"))+average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))+average(getData("ILBL_SEL:pwr"))
	avg_pwr_w = average(getData("ICOL1.ICOL_LBL.ICDA:pwr"))
    else
	;; measure delays
	;; BL discharge and precharge delay
	dly_bl_pch = cross(v("BLB") VDD*.95 1 'rising) - cross(v("PCH") VDD/2 1 'falling) 
	dly_writeDriver = cross(v("BLB") VDD*.05 1 'falling) - cross(v("WEN") VDD*0.05 1 'rising)
	;;dly_writeDriver = cross(v("ICOL1.IBCA.QB") VDD*.05 1 'falling) - cross(v("WEN") VDD/2 1 'rising)
	delay_inter_w=cross(v("WEN") VDD*.05 1 'rising) - cross(v("WEN_IN") VDD/2 1 'rising)

	;; measure power
	; accessed col cd and bitcell power
	avg_pwr_writeDriver = average(getData("IWRD:pwr"))+average(getData("IWRDB:pwr"))
	avg_pwr_int_w=average(getData("IWEN:pwr"))+average(getData("IPCH1:pwr"))+ <ws>*average(getData("IPCH_buf:pwr"))
	avg_pwr_w = average(getData("ICOL1.ICDA:pwr"))
	)
	
	; half-selected col cd and bitcell power if col-mux present
	if( colMux > 1 then
      if( Local_BL == "true" then
		avg_pwr_hs = average(getData("ICOLD.ICOL_LBL.ICDA:pwr")) + average(getData("ICOLD.ICOL_LBLD.ICDA:pwr"))
		avg_pwrbc_hs = average(getData("ICOLD.ICOL_LBL.IBCA:pwr")) + average(getData("ICOLD.ICOL_LBLD.IBCA:pwr"))
      else
		avg_pwr_hs = average(getData("ICOLD.ICDA:pwr"))
		avg_pwrbc_hs = average(getData("ICOLD.IBCA:pwr"))
        )
	else
		avg_pwr_hs = 0
		avg_pwrbc_hs = 0
	)
	
	; calculate total CD energy across all selected columns
	energycd_w = <ws>*(avg_pwr_w + avg_pwr_hs)*1.3*<tper>
	energybc_w = <ws>*(avg_pwrbc_w + avg_pwrbc_hs)*1.3*<tper>
	energy_writeDriver= <ws>*avg_pwr_writeDriver*1.3*<tper>	
	energy_inter_w=avg_pwr_int_w*1.3*<tper>

	;; write data to file
	fprintf(of,"%d\t%d\t%d\t%e\t%e\t%e\t%e\t%e\t%e\t%e\t%e\n", <numBanks>, rows, colMux, dly_bl_pch, dly_writeDriver, dly_bcwr, energycd_w, energybc_w, energy_writeDriver, energy_inter_w, delay_inter_w)
	rows = rows*rowStep
	drain(of)
)
close(of)

