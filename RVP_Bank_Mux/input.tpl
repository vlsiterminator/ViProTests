;;Modified output delay equation. 11/25/2014.
;;Increased the simulation time to 5ns. 2/12/2015.
/*
 Ocean script to measure inverter chain energy
 
 Author		Satya
 Date		04/17/2011
 Modified by Ningxi
 Date  2015/1/14
 1) Increased the simulation time and <pwidth> to 3ns to allow DOUT reaching VDD/2
 2) Updated Bankmux instance related test
*/

; ************************** main code ***************************
simulator( 'spectre )

;; COPY THE CORRISPONDING NETLIST FOR THE DESIRED DATA PATTERN
design( "./netlist" )

resultsDir("./OUT")

modelFile( 
	'("<include>")
	'("<subN>")
	'("<subP>")
)

out = outfile("data.txt", "w")

desVar(   "pvdd" <pvdd>)
desVar(   "pvbp" <pvdd>)
desVar(   "ldef" <ldef> )
desVar(   "wdef" <wdef> )
desVar(   "prise" <prise> )
desVar(   "pfall" <pfall> )
desVar(   "pwidth" <pwidth> )
desVar(   "ws" <ws> )
desVar(   "cwl" <cwl>)
desVar(   "cg" <cg>)
desVar( "colMux" <colMux>)
desVar( "numBanks" <numBanks>)
VDD=<pvdd>

char = <char>

if( (<numBanks> == 1) then
fprintf(out,"%d\t%d\t%d\t%d\t%d\t%d\n",<numBanks>,<colMux>,0,0,0,0)
close(out)
else

		analysis('tran ?start 0 ?stop 5*1e-9 ?step 0.01n ?strobeperiod 0.001n ?errpreset 'conservative)
		temp(25)
		option('reltol 1e-6 'gmin 1e-22)
		save('all)
		run()
		selectResults('tran)
	
		
	
		;;interCon_energy = 3*1e-9*(average(getData("IBANK_SEL0:pwr"))+average(getData("IBANK_SELB0:pwr")))
		interCon_energy = 5*1e-9*average(getData("IBANK_SEL0:pwr"))
		;;e_Tri_ivn = 3*1e-9*average(getData("Tri_state0:pwr"))*<ws>
		e_Tri_ivn = 5*1e-9*(average(getData("Tri_state0:pwr"))+average(getData("IData_buf:pwr")))*<ws>
		
			
		;;propagation delay through buffer chain to output tristate
		interCon_delay=cross(v("BANK_SEL_OUT0") VDD/2 1 'rising) -cross(v("BANK_SEL0") VDD/2 1 'rising)
		;; propagation delay from tristate to DFF over bank interconnect
        ;; Changed how the ouput delay is calculated, which seems the same with origin equation, but the original one doesn't work.
		;;bank_output_delay= cross(v("DATA_OUT0") VDD/2 1 'rising) -cross(v("BANK_SEL_OUT0") VDD/2 1 'rising)
		bank_output_delay= cross(v("DATA_OUT0") VDD/2 1 'rising) 
	fprintf(out,"%d\t%d\t%e\t%e\t%e\t%e\n", <numBanks>,<colMux>, e_Tri_ivn, bank_output_delay-interCon_delay, interCon_energy, interCon_delay)

close(out)
)
