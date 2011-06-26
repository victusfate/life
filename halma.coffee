getCursorPosition = halmaOnClick = clickOnEmptyCell = clickOnPiece = isThereAPieceBetween = isTheGameOver = drawBoard = null
newGame = endGame = initGame = null

gPieces = gNumPieces = gSelectedPieceIndex = gSelectedPieceHasMoved = gMoveCount = gGameInProgress = gDrawingContext = gMoveCountElem = null
gCanvasElement = gGameInProgress = null

Cell = (row, column) ->
	@row = row
	@column = column
	
getCursorPosition = (e) ->
	if e.pageX != undefined and e.pageY != undefined
		x = e.pageX
		y = e.pageY
	else
		x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
		y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
	x -= gCanvasElement.offsetLeft
	y -= gCanvasElement.offsetTop
	x = Math.min(x, kBoardWidth * kPieceWidth)
	y = Math.min(y, kBoardHeight * kPieceHeight)
	cell = new Cell(Math.floor(y / kPieceHeight), Math.floor(x / kPieceWidth))
	cell
	
halmaOnClick = (e) ->
	cell = getCursorPosition(e)
	i = 0
	
	while i < gNumPieces
		if (gPieces[i].row == cell.row) and (gPieces[i].column == cell.column)
			clickOnPiece i
			return
		i++
	clickOnEmptyCell cell
	
clickOnEmptyCell = (cell) ->
	return	if gSelectedPieceIndex == -1
	rowDiff = Math.abs(cell.row - gPieces[gSelectedPieceIndex].row)
	columnDiff = Math.abs(cell.column - gPieces[gSelectedPieceIndex].column)
	if (rowDiff <= 1) and (columnDiff <= 1)
		gPieces[gSelectedPieceIndex].row = cell.row
		gPieces[gSelectedPieceIndex].column = cell.column
		gMoveCount += 1
		gSelectedPieceIndex = -1
		gSelectedPieceHasMoved = false
		drawBoard()
		return
	if (rowDiff == 2) and (columnDiff == 0) or (rowDiff == 0) and (columnDiff == 2) or (rowDiff == 2) and (columnDiff == 2) and isThereAPieceBetween(gPieces[gSelectedPieceIndex], cell)
		gMoveCount += 1	unless gSelectedPieceHasMoved
		gSelectedPieceHasMoved = true
		gPieces[gSelectedPieceIndex].row = cell.row
		gPieces[gSelectedPieceIndex].column = cell.column
		drawBoard()
		return
	gSelectedPieceIndex = -1
	gSelectedPieceHasMoved = false
	drawBoard()
	
clickOnPiece = (pieceIndex) ->
	return	if gSelectedPieceIndex == pieceIndex
	gSelectedPieceIndex = pieceIndex
	gSelectedPieceHasMoved = false
	drawBoard()
	
isThereAPieceBetween = (cell1, cell2) ->
	rowBetween = (cell1.row + cell2.row) / 2
	columnBetween = (cell1.column + cell2.column) / 2
	i = 0
	
	while i < gNumPieces
		return true	if (gPieces[i].row == rowBetween) and (gPieces[i].column == columnBetween)
		i++
	false
	
isTheGameOver = ->
	i = 0
	
	while i < gNumPieces
		return false	if gPieces[i].row > 2
		return false	if gPieces[i].column < (kBoardWidth - 3)
		i++
	true
	
drawBoard = ->
	endGame()	if gGameInProgress and isTheGameOver()
	gDrawingContext.clearRect 0, 0, kPixelWidth, kPixelHeight
	gDrawingContext.beginPath()
	x = 0
	
	while x <= kPixelWidth
		gDrawingContext.moveTo 0.5 + x, 0
		gDrawingContext.lineTo 0.5 + x, kPixelHeight
		x += kPieceWidth
	y = 0
	
	while y <= kPixelHeight
		gDrawingContext.moveTo 0, 0.5 + y
		gDrawingContext.lineTo kPixelWidth, 0.5 + y
		y += kPieceHeight
	gDrawingContext.strokeStyle = "#ccc"
	gDrawingContext.stroke()
	i = 0
	
	while i < 9
		drawPiece gPieces[i], i == gSelectedPieceIndex
		i++
	gMoveCountElem.innerHTML = gMoveCount
	saveGameState()
	
drawPiece = (p, selected) ->
	column = p.column
	row = p.row
	x = (column * kPieceWidth) + (kPieceWidth / 2)
	y = (row * kPieceHeight) + (kPieceHeight / 2)
	radius = (kPieceWidth / 2) - (kPieceWidth / 10)
	gDrawingContext.beginPath()
	gDrawingContext.arc x, y, radius, 0, Math.PI * 2, false
	gDrawingContext.closePath()
	gDrawingContext.strokeStyle = "#000"
	gDrawingContext.stroke()
	if selected
		gDrawingContext.fillStyle = "#000"
		gDrawingContext.fill()
		
newGame = ->
	gPieces = [ new Cell(kBoardHeight - 3, 0), new Cell(kBoardHeight - 2, 0), new Cell(kBoardHeight - 1, 0), new Cell(kBoardHeight - 3, 1), new Cell(kBoardHeight - 2, 1), new Cell(kBoardHeight - 1, 1), new Cell(kBoardHeight - 3, 2), new Cell(kBoardHeight - 2, 2), new Cell(kBoardHeight - 1, 2) ]
	gNumPieces = gPieces.length
	gSelectedPieceIndex = -1
	gSelectedPieceHasMoved = false
	gMoveCount = 0
	gGameInProgress = true
	drawBoard()
	
endGame = ->
	gSelectedPieceIndex = -1
	gGameInProgress = false
	
initGame = (canvasElement, moveCountElement) ->
	unless canvasElement
		canvasElement = document.createElement("canvas")
		canvasElement.id = "halma_canvas"
		document.body.appendChild canvasElement
	unless moveCountElement
		moveCountElement = document.createElement("p")
		document.body.appendChild moveCountElement
	gCanvasElement = canvasElement
	gCanvasElement.width = kPixelWidth
	gCanvasElement.height = kPixelHeight
	gCanvasElement.addEventListener "click", halmaOnClick, false
	gMoveCountElem = moveCountElement
	gDrawingContext = gCanvasElement.getContext("2d")
	newGame()	unless resumeGame()
	
kBoardWidth = 9
kBoardHeight = 9
kPieceWidth = 50
kPieceHeight = 50
kPixelWidth = 1 + (kBoardWidth * kPieceWidth)
kPixelHeight = 1 + (kBoardHeight * kPieceHeight)

window.initGame = initGame

unless typeof resumeGame == "function"
	saveGameState = ->
		false
	
	resumeGame = ->
		false