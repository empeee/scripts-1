#!/bin/bash                                                                                                                                           
# Usage: run_xor <gds1> <cell name> <gds2> <cell name>                                                                                                
# First create a rule file                                                                                                                            
$MGC_HOME/bin/dbdiff -system GDS -design $1 $2 -refdesign $3 $4 -write_xor_rules rules.xor xor                                                        
                                                                                                                                                      
# Next, run the DRC job                                                                                                                               
$MGC_HOME/bin/calibre -drc -hier rules.xor | tee xor.log           
