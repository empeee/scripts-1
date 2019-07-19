procedure(scrubSchematic( )
	let(( )
		;Get current window cellview for edit
		cv = geGetEditCellView()
		
		printf("Processing lib:%s cell:%s view:%s\n" cv~>libName cv~>cellName cv~>cellViewType)

		if(cv~>cellViewType=="schematic" then
			;Get all wire labels
			labels = setof(x cv~>shapes x~>lpp==list("wire" "label"))
			
			printf("Wire Labels\n")
			foreach(label labels
				printf("%L " label~>theLabel)
				;Change height
				label~>height = 0.0625
			)
			
			;Get all pin labels
			printf("\n\n\nTerminals\n")
			foreach(term cv~>terminals
				labelList = car(term~>pins~>fig~>children)
				
				printf("%L " term~>name)
				foreach(label labelList
					;Change height
					label~>height = 0.0625
				)
			)
			printf("\n")
		else
			printf("Not a schematic view... aborting...\n")
		)	
	)
	)
			
