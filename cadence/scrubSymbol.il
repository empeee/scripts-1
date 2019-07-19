procedure(scrubSymbol( )
	let(( )
		cv = geGetEditCellView()
		
		printf("Processing lib:%s cell:%s view:%s\n" cv~>libName cv~>cellName cv~>cellViewType)

		if(cv~>cellViewType=="schematicSymbol" then
			;Find selection box - we use it to determine label location
			selShape = car(setof(x cv~>shapes x~>lpp=='("instance" "drawing")))
			selbBox = selShape~>bBox
			selll = car(selbBox)  ; Lower left point
			selur = cadr(selbBox) ; Upper right point
			
			;Find x-axis centerline
			selxCenter = (xCoord(selll)+xCoord(selur))/2
			
			;Look for short symbols, treated differently
			selHeight = yCoord(selur)-yCoord(selll)
			if(selHeight<2 then
				labelOffset = selHeight/2
			else
				labelOffset = 1
			)
			if(selHeight<1.5 then
				rotateTopBottom = nil
			else
				rotateTopBottom = t
			)

			;Force user to create selection box if none exists
			if(selbBox==nil then
				printf("No selection box found. Please add one so I can find pin and label direction\n")
			else
				;Find and adjust instanceName label or create
				printf("Instance Name Label ")
				instNameLabel = car(setof(x cv~>shapes x~>theLabel=="[@instanceName]"))
				if(instNameLabel==nil then
					printf("not found, creating... ")
					instNameLabel = dbCreateLabel(cv list("instance" "label") 0:0 "" "lowerLeft" "R0" "stick" 0.0625)
				)
				
				instNameLabel~>lpp = list("instance" "label")
				instNameLabel~>xy = xCoord(selur):yCoord(selur)-0.25+0.03125
				instNameLabel~>theLabel = "[@instanceName]"
				instNameLabel~>justify = "lowerRight"
				instNameLabel~>orient = "R0"
				instNameLabel~>font = "stick"
				instNameLabel~>height = 0.125
				instNameLabel~>labelType = "NLPLabel"
				printf("\n")

				;Find and adjust cellName label or create
				printf("Cell Name Label ")
				cellNameLabel = car(setof(x cv~>shapes x~>theLabel=="[@cellName]"))
				if(cellNameLabel==nil then
					printf("not found, creating... ")
					cellNameLabel = dbCreateLabel(cv list("instance" "label") 0:0 "" "lowerLeft" "R0" "stick" 0.0625)
				)
				
				;cellNameLabel~>lpp = list("instance" "label") ; Synaptics
				cellNameLabel~>lpp = list("device" "label") ; Sony
				cellNameLabel~>xy = selxCenter:yCoord(selur)-labelOffset
				cellNameLabel~>theLabel = "[@cellName]"
				cellNameLabel~>justify = "lowerCenter"
				cellNameLabel~>orient = "R0"
				cellNameLabel~>font = "stick"
				cellNameLabel~>height = 0.125
				cellNameLabel~>labelType = "NLPLabel"
				printf("\n")

				;Find and adjust libName label or create
				printf("Lib Name Label ")
				libNameLabel = car(setof(x cv~>shapes x~>theLabel=="[@libName]"))
				if(libNameLabel==nil then
					printf("not found, creating... ")
					libNameLabel = dbCreateLabel(cv list("instance" "label") 0:0 "" "lowerLeft" "R0" "stick" 0.0625)
				)
				
				;libNameLabel~>lpp = list("instance" "label") ; Synaptics
				libNameLabel~>lpp = list("device" "label") ; Sony
				libNameLabel~>xy = selxCenter:yCoord(selur)-labelOffset-0.125
				libNameLabel~>theLabel = "[@libName]"
				libNameLabel~>justify = "lowerCenter"
				libNameLabel~>orient = "R0"
				libNameLabel~>font = "stick"
				libNameLabel~>height = 0.0625
				libNameLabel~>labelType = "NLPLabel"
				printf("\n")
				
				;Go through symbol pin by pin to fix
				foreach(term cv~>terminals
					printf("Terminal %L " term~>name)
					
					;Find any and all attached labels
					labelList = car(term~>pins~>fig~>children)
					
					;Get pin shape for reshaping
					pinFig = car(term~>pins~>fig)
					pinDir = term~>direction\n
					
					;Assume there is no pin name label or cdsTerm label
					cdsTermLabel = nil
					pinNameLabel = nil
					
					foreach(label labelList
						printf("Label:%L " label~>theLabel) ;Get label text
						
						;Determine if pin name label and/or cdsTerm label exists
						if(label~>labelType=="ILLabel"     then cdsTermLabel = label)
						if(label~>labelType=="normalLabel" then pinNameLabel = label)
					)

					;Find pin origin point from terminal bBox, used for label reference
					termbBox = car(term~>pins~>fig~>bBox)
					termxOrig = (caar(termbBox)+caadr(termbBox))/2
					termyOrig = (cadar(termbBox)+cadadr(termbBox))/2
					termOrig = termxOrig:termyOrig
					
					
					;Build cdsTerm string in case we need it
					cdsTermString = buildString(list(concat("cdsTerm(\""  term~>name "\")" )))
					
					;If cdsTerm label does not exist, create it
					if(cdsTermLabel==nil then
						printf("cdsTerm label not found, creating...")
						cdsTermLabel = dbCreateLabel(cv list("annotate" "drawing8") termOrig "" "lowerLeft" "R0" "stick" 0.0625)
					)

					;Force side-independent cdsTerm label properties
					cdsTermLabel~>lpp = list("annotate" "drawing8")	
					cdsTermLabel~>theLabel = cdsTermString	
					cdsTermLabel~>font = "stick"
					cdsTermLabel~>height = 0.0625	
					cdsTermLabel~>labelType = "ILLabel"	
					leAttachFig(cdsTermLabel car(term~>pins~>fig))
					
					;If pinNameLabel exists, force side-independent properties
					if(pinNameLabel!=nil then
						pinNameLabel~>lpp = list("pin" "label")	
						pinNameLabel~>theLabel = pinNameLabel~>theLabel	
						pinNameLabel~>font = "stick"
						pinNameLabel~>height = 0.0625	
						pinNameLabel~>labelType = "normalLabel"	
					)

					if(xCoord(termOrig)==xCoord(selll) then
						;Left side pin
						printf("Left side... ")
						
						;Force side-dependent cdsTerm properties
						cdsTermLabel~>xy = xCoord(termOrig):yCoord(termOrig)+0.03125
						cdsTermLabel~>justify = "lowerRight"
						cdsTermLabel~>orient = "R0"
						
						;If pin name label exists fix location, justification, and rotation
						;Don't create it if its not already there (e.g. logic symbols)
						if(pinNameLabel then
							pinNameLabel~>xy = xCoord(termOrig)+0.3125:yCoord(termOrig)
							pinNameLabel~>justify = "centerLeft"
							pinNameLabel~>orient = "R0"
						)
					else if(xCoord(termOrig)==xCoord(selur) then
						;Right side pin
						printf("Right side... ")
						
						;Force side-dependent cdsTerm properties
						cdsTermLabel~>xy = xCoord(termOrig):yCoord(termOrig)+0.03125
						cdsTermLabel~>justify = "lowerLeft"
						cdsTermLabel~>orient = "R0"
						
						;If pin name label exists fix location, justification, and rotation
						;Don't create it if its not already there (e.g. logic symbols)
						if(pinNameLabel then
							pinNameLabel~>xy = xCoord(termOrig)-0.3125:yCoord(termOrig)
							pinNameLabel~>justify = "centerRight"
							pinNameLabel~>orient = "R0"
						)		
					else if(yCoord(termOrig)==yCoord(selll) then
						;Bottom side pin
						printf("Bottom side... ")
						
						;Force side-dependent cdsTerm properties
						cdsTermLabel~>xy = xCoord(termOrig)-0.03125:yCoord(termOrig)
						cdsTermLabel~>justify = "lowerRight"
						cdsTermLabel~>orient = "R90"
						
						;If pin name label exists fix location, justification, and rotation
						;Don't create it if its not already there (e.g. logic symbols)
						if(pinNameLabel then
							pinNameLabel~>xy = xCoord(termOrig):yCoord(termOrig)+0.3125
							if(rotateTopBottom then
								pinNameLabel~>justify = "centerLeft"
								pinNameLabel~>orient = "R90"
							else
								pinNameLabel~>justify = "centerCenter"
								pinNameLabel~>orient = "R0"
							)	
						)		
					else if(yCoord(termOrig)==yCoord(selur) then
						;Top side pin
						printf("Top side... ")
						
						;Force side-dependent cdsTerm properties
						cdsTermLabel~>xy = xCoord(termOrig)-0.03125:yCoord(termOrig)
						cdsTermLabel~>justify = "lowerLeft"
						cdsTermLabel~>orient = "R90"
						
						;If pin name label exists fix location, justification, and rotation
						;Don't create it if its not already there (e.g. logic symbols)
						if(pinNameLabel then
							pinNameLabel~>xy = xCoord(termOrig):yCoord(termOrig)-0.3125
							if(rotateTopBottom then
								pinNameLabel~>justify = "centerRight"
								pinNameLabel~>orient = "R90"
							else
								pinNameLabel~>justify = "centerCenter"
								pinNameLabel~>orient = "R0"
							)	
						)		
					else
						;Pin is not on the selection box. Complain...
						printf("Pin not on Selection Box, can't adjust label position.")
					))))
					
					printf("\n")
				)	
			)		
		else
			printf("Not a symbol view... aborting...\n")
		)			
	)				
)
