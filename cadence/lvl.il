SS FOR A PARTICULAR USE.                                           *
*******************************************************************************/

procedure(bulkRename()
    let((lib_name origPrefix newPrefix)
        lib_name=hiCreateStringField(
            ?name 'srcLibName
            ?prompt "Enter source library"
            ?value ""
            ?defValue ""
        )

        origPrefix=hiCreateStringField(
            ?name 'prefixName
            ?prompt "Enter original prefix"
            ?value ""
            ?defValue ""
        )

        newPrefix=hiCreateStringField(
            ?name 'newPrefixName
            ?prompt "Enter new prefix"
            ?value ""
            ?defValue ""
        )

        overwrite=hiCreateRadioField(
            ?name 'ovrwr
            ?prompt "Overwrite?"
            ?value "True"
            ?choices '("True" "False")
        )

        hiCreateAppForm( ?name 'nameForm
            ?formTitle "Bulk Rename GUI"
            ?fields list(lib_name origPrefix newPrefix overwrite)
            ?callback "CCSRenameCell()"
        )

        hiDisplayForm(nameForm)
    );let
);procedure


procedure( CCSRenameCell( )
    let( ( srcSpec destSpec newCellName ovrFlag)

        overwrite=nameForm->ovrwr->value
        libName=nameForm->srcLibName->value
        origPrefix=nameForm->prefixName->value
        newPrefix=nameForm->newPrefixName->value

        if(overwrite=="True" then ovrFlag = `TRUE
            else ovrFlag = `FALSE
        ); if

        foreach(cell ddGetObj(libName)~>cells
            rexCompile(sprintf(nil "^%s" origPrefix))

            if(rexExecute(cell~>name) then
                newCellName = rexReplace(cell~>name newPrefix 0)
                srcSpec = gdmCreateSpec(libName cell~>name "" "" "CDBA")
                destSpec = gdmCreateSpec(libName newCellName "" "" "CDBA")
                ccpRename(srcSpec destSpec ovrFlag `CCP_EXPAND_ALL `CCP_UPDATE_DESTLIB_ONLY)
            ) ; if
       );foreach
   ) ; let
) ; procedure
