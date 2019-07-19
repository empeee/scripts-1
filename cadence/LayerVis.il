/* 
This function manages visible layers in the LSW

Will load a file named "custom_layers.il" from the working directory
1st then from home directory
if neither exists, it will use a default setting.

*/

;/*Loading "custom_layers.il" from working directory or home directory and setting defaults if files do not exist*/
if( isFile(sprintf(custom_layers_file "%s/custom_layers.il" getWorkingDir())) then
  println( custom_layers_file)
  load(custom_layers_file)
else
  ;/*DEFAULT GROUPS*/
grp1=list( 
'("Met1" "drawing")
'("Contact" "drawing")
'("Met1" "pin")
'("Met1" "net")
'("Met1_close" "close")
'("Met1_open" "open")
'("Met1_text" "text")
);end grp1

grp2=list(
'("Met2" "drawing")
'("Via1" "drawing")
'("Met2" "pin")
'("Met2" "net")
'("Met2_text" "text")
);end grp2

grp3=list(
'("Met3" "drawing")
'("Via2" "drawing")
'("Met3" "pin")
'("Met3" "net")
'("Met3_text" "text")
);end grp3

grp4=list(
'("Met4" "drawing")
'("Via3" "drawing")
'("Met4" "pin")
'("Met4" "net")
'("Met4_text" "text")
);end grp4

grp5=list(
'("Met5" "drawing")
'("Via4" "drawing")
'("Met5" "pin")
'("Met5" "net")
'("Met5_text" "text")
);end grp5

grp6=list(
'("Met6top" "drawing")
'("Via5top" "drawing")
'("Met6top" "pin")
'("Met6top" "net")
'("Met6_text" "text")
);end grp6

grp7=list(
'("Poly" "drawing")
'("Pwell" "drawing")
'("Pwell_text" "text") 
'("Nwell" "drawing")
'("Nwell" "net")
'("Island" "drawing")
'("Island" "net") 
'("Island_text" "text")
'("HVNisland" "drawing")
'("HVPisland" "drawing")
'("Thickox" "drawing")
'("Poly" "pin")
'("Poly" "net")
'("Poly_text" "text")
'("HRPoly" "drawing")
'("Pselect" "drawing")
'("Nselect" "drawing")
'("Contact" "drawing") 
'("LVNLDD" "drawing")
'("LVPLDD" "drawing")
'("MVNLDD" "drawing")
'("MVPLDD" "drawing")
'("LDNwell" "drawing")
'("MDNwell" "drawing")
'("MVPwell" "drawing")
'("MVNwell" "drawing")
'("HVPwell" "drawing")
'("HVNwell" "drawing")
);end grp7

grpIGNORE=list(
'("prBoundary" "drawing")
'("instance" "drawing")
'("text" "drawing")
'("y0" "drawing") 
'("y1" "drawing")
'("y2" "drawing") 
'("y3" "drawing") 
'("y4" "drawing") 
'("y5" "drawing")
'("y6" "drawing") 
'("y7" "drawing")
'("y8" "drawing") 
'("y9" "drawing")
);end IGNORE

);/*end if*/

;/*LayerVis procedure*/
procedure(LayerVis(l_layers ;/*required arguments*/
@optional (p_toggle nil)
);/*end arguments*/

  prog( () 
  ;/*function modifies selected layer if toggled to not visible*/
    p_vis=t
    p_hide_others=t
    if( p_toggle then
      p_vis=!LayerVisGetState(l_layers)
      if( !p_vis && member( leGetEntryLayer() l_layers) then 
        leSetEntryLayer(FindNewEntryLayer(l_layers))
        );/*end if*/
      p_hide_others=nil
    );/*end if*/

    ;/*SPECIAL CASE - not in list of layers*/
    if( !listp(l_layers) then
      case( upperCase(l_layers)
        ("ALL"  
        SetLayersVisible(grpIGNORE t)
        hiRedraw()
        return()
        );/*end case ALL*/
        (t
        return(println("Unrecognized argument"))
        );/*end catchall*/
      );/*end case*/
    );/*end if*/
    ;/*END SPECIAL CASE*/

    if(p_vis then 
      leSetEntryLayer(car(l_layers))
    );/*end if*/
    if(p_hide_others then 
      SetLayersVisible(grpIGNORE nil)
    );/*end if*/
    foreach(layer l_layers
      leSetLayerVisible( layer p_vis )
    );/*end foreach*/
    hiRedraw()
    return(t)
  );/*end prog*/
);/*end procedure LayerVis*/

;/*LayerVisGetState procedure*/
procedure(LayerVisGetState(l_layers)
  prog( () 
  ;/*function returns t if all layers in the list are visible, nil otherwise*/
    foreach( layer l_layers
      if( !leIsLayerVisible(layer) then 
        return(nil)
      );/*end if*/
    );/*end foreach*/
    return(t)
  );/*end prog*/
);/*end procedure LayerVisGetState*/

;/*SetLayersVisible procedure*/
procedure(SetLayersVisible(l_ignore p_visible)
  prog( ()
    techfile_dbId=techGetTechFile(geGetEditCellView()) ;/*changed from techfile_dbId=FindTechFile()*/
    foreach( layer leGetValidLayerList(techfile_dbId)
      if( !member(layer cons(leGetEntryLayer(techfile_dbId) l_ignore)) then 
        leSetLayerVisible( layer p_visible )
      );/*end if*/
    );/*end foreach*/
  );/*end prog*/
);/*end procedure SetLayersVisible*/

/*FindNewEntryLayer procedure*/
procedure(FindNewEntryLayer(l_layers)
  prog( ()
    techfile_dbId=techGetTechFile(geGetEditCellView()) ;/*changed from techfile_dbId=FindTechFile()*/
    l_layers_out=nil
    foreach( layer leGetValidLayerList(techfile_dbId)
      if( leIsLayerVisible( layer ) && !member( layer l_layers ) then 
        l_layers_out=cons(layer l_layers_out)
      );/*end if*/
    );/*end foreach*/
    if( !l_layers_out then
      return( car(leGetValidLayerList(techfile_dbId))
    );/*end if*/
    else
      return( car(reverse(l_layers_out)))
    );/*endif*/
  );/*end prog*/
);/*end procedure FindNewEntryLayer*/

;/*FindTechFile procedure*/
procedure(FindTechFile()
  prog( ()
  ;/*function finds correct tech file*/
    l_techfile_dbId=techGetOpenTechFiles() ;/*lists tech files open - encrypted*/
    l_techfile_dbId_subset=setof( techfile l_techfile_dbId lowerCase(techfile~>libName)==getShellEnvVar("CAD_PROCESS") || techfile~>libName=="LIBNAMEHERE")
    if( length(l_techfile_dbId_subset) != 1 then
      lib_prop_list = getCurrentWindow()~>cellView~>lib~>prop
      foreach( lib_prop lib_prop_list
        if( strcmp(lib_prop~>name, "techLibName")==0 then 
          techfile_name=lib_prop~>value
        );/*end if*/
      );/*end foreach*/
      foreach(possible_techfile_dbID l_techfile_dbId_subset
        if( strcmp(possible_techfile_dbID~>libName techfile_name)==0 then 
          techfile_dbId=possible_techfile_dbID
        );/*end if*/
      );/*end foreach*/
    else
      techfile_dbId=car(l_techfile_dbId_subset)
    );/*end if*/
  return(techfile_dbId)
  );/*end prog*/
);/*end procedure FindTechFile*/

