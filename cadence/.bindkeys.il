;/*Loading "LayerVis.il" from user's scripts directory (if exists) or owner's scripts directory */
if( isFile(sprintf(layer_vis_file "~/scripts/LayerVis.il" )) then
  println(layer_vis_file)
  load(layer_vis_file)
)

;/*Loading "scrubSchematic.il" from user's scripts directory (if exists) or owner's scripts directory */
if( isFile(sprintf(scrub_schematic_file "~/scripts/scrubSchematic.il" )) then
  println(scrub_schematic_file)
  load(scrub_schematic_file)
)

;/*Loading "scrubSymbol.il" from user's scripts directory (if exists) or owner's scripts directory */
if( isFile(sprintf(scrub_symbol_file "~/scripts/scrubSymbol.il" )) then
  println(scrub_symbol_file)
  load(scrub_symbol_file)
)

;*****************************************************************************************************************

;   ***** BEGIN - custom schematic/symbol bindkeys *****

hiSetBindKeys( "Schematics" list(
list("<Key>0" "geDeleteAllProbe(getCurrentWindow() t)")
list("<Key>8" "geDeleteNetProbe()") ;UN-probe a single net
list("<Key>s" "scrubSchematic()")
))

hiSetBindKey("Symbol" "<Key>s" "scrubSymbol()")

;   ***** END - custom schematic/symbol binkeys *****

;*****************************************************************************************************************

;   ***** BEGIN - custom layout binkeys *****

hiSetBindKeys( "Layout" list(

list("<Key>1"                   "LayerVis(grp1)" "")   ;setting Metal 1 and Via
list("<Key>2"                   "LayerVis(grp2)" )     ;setting Metal 2 and Via
list("<Key>3"                   "LayerVis(grp3)" )     ;setting Metal 3 and Via
list("<Key>4"                   "LayerVis(grp4)" )     ;setting Metal 4 and Via
list("<Key>5"                   "LayerVis(grp5)" )     ;setting Metal 5 and Via
list("<Key>6"                   "LayerVis(grp6)" )     ;setting Metal 6 and Via
list("<Key>7"                   "LayerVis(grp7)" )     ;setting AD(Metal7ish) and Via
list("<Key>8"                   "LayerVis(grp8)" )     ;setting Active
list("<Key>0"                   "LayerVis(\"ALL\")" )  ;setting All layers visible                      
list("Alt<Key>1"                "LayerVis(grp1 t)" )   ;toggling Metal 1 and Via
list("Alt<Key>2"                "LayerVis(grp2 t)" )   ;toggling Metal 2 and Via
list("Alt<Key>3"                "LayerVis(grp3 t)" )   ;toggling Metal 3 and Via
list("Alt<Key>4"                "LayerVis(grp4 t)" )   ;toggling Metal 4 and Via
list("Alt<Key>5"                "LayerVis(grp5 t)" )   ;toggling Metal 5 and Via
list("Alt<Key>6"                "LayerVis(grp6 t)" )   ;toggling Metal 6 and Via
list("Alt<Key>7"                "LayerVis(grp7 t)" )   ;toggling AD and Via
list("Alt<Key>8"                "LayerVis(grp8 t)" )   ;toggling Active

;Bindkey to turn off annoying stretch thing
list("<DrawThru1>"	"geSingleSelectBox()"	"geSingleSelectBox()")


;Bindkey to disable DRD toggle
list("Ctrl<Key>E"		"")

;Align bindkey
list("Alt<Key>A"		"leHiAlign()")

list("Alt<Key>E"		"selSame()")

;Bindkey to disable wire default
list("<Key>P"                   "leHiCreatePath()")

list("Ctrl Alt<Btn3Down>"       "snapToggle()" "snapToggle()")   ;EF

; Bindkey for MPPS
list("Ctrl Alt<Key>m"           "leHiCreateMPP()")


list("Ctrl Alt<Btn1Down>"       "leSetEnv(\"orientation\" \"MX\")"  "leSetEnv(\"orientation\" \"MX\")")
list("Ctrl Alt<Btn2Down>"       "leSetEnv(\"orientation\" \"MY\")" "leSetEnv(\"orientation\" \"MY\")")
list("Alt<Key>s"                "leZoomToSelSet()")
list("<Key>F1"                  "{geDeselectAllFig()} {listSelected()}")
list("Shift<Key>e"              "leHiEditInPlace()")

); end layout bindkeys
);end set bindkeys command

procedure( snapToggle()
leCycleSnapModes()
if( hiGetCurrentWindow()->snapMode == "anyAngle" then leCycleSnapModes())
);end proc

procedure(selSame()
     let(( cv cellSelName libSelName allCells cellInView )
       if( (geGetSelSetCount() == 1 && car(geGetSelSet()~>objType) == "inst") then
         cv = geGetSelSet()
         cellSelName = car(cv~>cellName)
         libSelName = car(cv~>libName)
         allCells = getEditRep()~>instances
         foreach(cellInView allCells
            if(cellInView~>cellName == cellSelName && cellInView~>libName == libSelName then
               geSelectFig(cellInView)
            ) ;if
         ) ;foreach
         t
       ) ;end if
   ) ;end let
)

;   ***** END - custom layout binkeys *****

;*****************************************************************************************************************

;   ***** BEGIN - custom ADE-L binkeys *****

hiRegisterBindKeyPrefix("Artist")
hiSetBindKeys( "Artist" list(
list("Ctrl<Key>o" "AFS_ViewSimulatorOutput(stringToSymbol(_vivaGetSessionName()))")
; list("Ctrl<Key>o" "_spectreViewSimulatorOutput(stringToSymbol(_vivaGetSessionName()))")
) ; END bindkey list
) ; END set bindkeys

;   ***** END - custom ADE-L binkeys *****

;*****************************************************************************************************************

;Load user specific display.drf
if( isFile(sprintf(custom_display_file "%s/my_display.drf" getWorkingDir())) ||
    isFile(sprintf(custom_display_file envGetVal("graphic" "drfPath"))) then
  envSetVal("graphic" "drfPath" 'string "")
  println(custom_display_file)
  drLoadDrf(custom_display_file nil)
)
