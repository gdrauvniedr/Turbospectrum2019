#!/bin/csh -f

date
set mpath=models

foreach MODEL (kurucz_3500_+0.00_-0.3.mod)





set lam_min    = '3800'
set lam_max    = '9200'

set deltalam   = '0.006'
set METALLIC   = '-0.3' 
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
'MARCS-FILE:' '.true.'
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
linelists/3500K_5000K_new.list     
'SPHERICAL:'  'F'  
  30        
  300.00   
  15
  1.30
EOF
########################################################################
date   
end   
