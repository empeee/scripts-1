; bulkPrefix.il
; Kevin Fronczak
; 2019-12-12

; load("bulkPrefix.il")
; bulkPrefix()


procedure(bulkPrefix()
  let((lib_name prefix_name suffix_name original_name list_cellid new_name cellview_opened)
    src_lib_name=hiCreateStringField(
      ?name 'srcLibName
      ?prompt "Enter the source Library name"
      ?value ""
      ?defValue ""
    )

    dest_lib_name=hiCreateStringField(
      ?name 'destLibName
      ?prompt "Enter the destination Library name"
      ?value ""
      ?defValue ""
    )

    prefix_name=hiCreateStringField(
      ?name 'prefixName
      ?prompt "Enter the prefix"
      ?value ""
      ?defValue ""
    )

    hiCreateAppForm( ?name 'nameForm
      ?formTitle "bulkPrefix.il GUI"
      ?fields list(src_lib_name dest_lib_name prefix_name suffix_name)
      ?callback "DBcopyCellToPrefix()"
    )


    hiDisplayForm(nameForm)
  );let
);procedure


procedure( DBcopyCellToPrefix( )
  let( ( d_libId g_srcList g_destList G_src G_dest )

    src_library=nameForm->srcLibName->value
    dest_library=nameForm->destLibName->value
    prefix=nameForm->prefixName->value
    s_libId = ddGetObj( src_library )

    g_srcList = gdmCreateSpecList( )
    g_destList = gdmCreateSpecList( )

    foreach( s_cell s_libId~>cells

      printf(
        "-- DBcopyCellToPrefix -- Copying cell %s to %s\n"
        s_cell~>name strcat( prefix s_cell~>name )
      )
      G_src = gdmCreateSpec( src_library s_cell~>name "" "" "CDBA")
      gdmAddSpecToSpecList( G_src g_srcList )
      G_dest = gdmCreateSpec( dest_library strcat( prefix s_cell~>name ) "" "" "CDBA")
      gdmAddSpecToSpecList( G_dest g_destList )
    ) ;; close foreach

    ccpCopy(
      g_srcList
      g_destList
      nil
      'CCP_EXPAND_ALL
    )
  ) ;; close let
) ;; close procedure
