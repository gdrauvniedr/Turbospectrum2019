#!/bin/csh -f

date
set mpath=models

foreach MODEL (p6000_g+4.40_m0.0_t01_ip_z+0.00_a+0.00_c+0.00_n+0.00_o+0.00_r+0.00_s+0.00.interpol)





set lam_min    = '6997.5'
set lam_max    = '7002.5'

set deltalam   = '0.001'
set METALLIC   = '0.0' 
set TURBVEL    = '1' 
set SUFFIX     = _${lam_min}-${lam_max}_xit${TURBVEL}.spec
set result     = ${MODEL} 

#
# ABUNDANCES FROM THE MODEL ARE NOT USED !!!

../exec-gf-v19.1/babsma_lu << EOF
'LAMBDA_MIN:'  '${lam_min}'
'LAMBDA_MAX:'  '${lam_max}'
'LAMBDA_STEP:' '${deltalam}'
'MODELINPUT:' '$mpath/${MODEL}'
'MARCS-FILE:' '.false.'
'MODELOPAC:' 'contopac/${MODEL}opac'
'METALLICITY:'    '${METALLIC}'
'ALPHA/Fe   :'    '0.00'
'HELIUM     :'    '0.00'
'R-PROCESS  :'    '0.00'
'S-PROCESS  :'    '0.00'
'INDIVIDUAL ABUNDANCES:'   '0'
'XIFIX:' 'T'
$TURBVEL
EOF
   
########################################################################

../exec-gf-v19.1/bsyn_lu <<EOF
'LAMBDA_MIN:'     '${lam_min}'
'LAMBDA_MAX:'     '${lam_max}'
'LAMBDA_STEP:'    '${deltalam}'
'INTENSITY/FLUX:' 'Flux'
'COS(THETA)    :' '1.00'
'ABFIND        :' '.false.'
'MODELOPAC:' 'contopac/${MODEL}opac'
'RESULTFILE :' 'output_spec/${result}'
'METALLICITY:'    '${METALLIC}'
'ALPHA/Fe   :'    '0.00'
'HELIUM     :'    '0.00'
'R-PROCESS  :'    '0.00'
'S-PROCESS  :'    '0.00'
'INDIVIDUAL ABUNDANCES:'   '0'
'ISOTOPES : ' '0'    
'NFILES   :' '2'  
DATA/Hlinedata   
linelists/3000_10000_exw_hfs.list     
'SPHERICAL:'  'F'  
  30        
  300.00   
  15
  1.30
EOF
########################################################################
date   
end   
