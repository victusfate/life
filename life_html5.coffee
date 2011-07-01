###
class MirrorWrapGrid
	constructor: (@rows,@cols) ->
		console.log "MirrorWrapGrid constructor"
		@data = []
		i=0
		while i < @rows
			@data[i] = []
			j=0
			while j < @cols
				@data[i][j] = 0
				j++
			i++

	wrap: (i,dim) ->
		usei = i
		if i < 0 
			usei = dim-1
		else if i >= dim
			usei = 0
		
	
	get: (i,j) ->
		usej = j
		if j < 0 
			usej = @ngridx-1
		else if j >= @ngridx
			usej = 0
		
	set: (i,j,val) ->
###
rcolors = ["rgba(255,255,255,1.0)","rgba(0,0,0,1.0)"]

class GameOfLife
	setPixel = live_or_die = random = update = clear = onMouseDown = onMouseMove = onMouseUp = setRegion = null
	
	constructor: (@width=800,@height=600,@ngridx=80,@ngridy=60,@element_id="canvasgol") ->
		console.log "GameOfLife constructor"
		@kCellWidth = @width/@ngridx
		@kCellHeight = @height/@ngridy
		@grid = []
		@newgrid = []
		@playpause = 0
		@time_out_id = null
		i=0
		while i < @ngridy
			@grid[i] = []
			@newgrid[i] = []
			j=0
			while j < @ngridx
				@grid[i][j] = 0
				@newgrid[i][j] = 0
				j++
			i++
		console.log "grid and newgrid set to zeros grid rows cols"
		
		@canvas = document.getElementById(@element_id) # canvas element
		console.log "got canvas id "+@element_id+ " canvas "+@canvas
		if @ctx = @canvas.getContext("2d")
			console.log "got context "+@ctx
			@canvas.width = @width
			@canvas.height = @height
			console.log "before drawing clear rectangle"
			@ctx.fillStyle = rcolors[0]
			@ctx.clearRect 0, 0, @ngridx*@kCellWidth, @ngridy*@kCellHeight
			console.log "after drawing clear rectangle"
			@canvas.onmousedown = @onMouseDown
			@canvas.onmousemove = @onMouseMove
			@canvas.onmouseup = @onMouseUp
			@canvas.getMouseLocation = @getMouseLocation
			console.log "before random"
			@random()
			console.log "after random"
			@displayGrid()

	drawGrid: () ->
		@ctx.beginPath()
		x = 0
		while x <= @width
			@ctx.moveTo 0.5 + x, 0
			@ctx.lineTo 0.5 + x, @height
			x += @kCellWidth
		y = 0
		while y <= @height
			@ctx.moveTo 0, 0.5 + y
			@ctx.lineTo @width, 0.5 + y
			y += @kCellHeight
		@ctx.strokeStyle = rcolors[1]
		@ctx.stroke()
		return


	setPixel: (imageData, x, y, r, g, b, a) ->
		index = (x + y * imageData.width)
		imageData.data[index + 0] = r
		imageData.data[index + 1] = g
		imageData.data[index + 2] = b
		imageData.data[index + 3] = a
		return

	setRegion: (x, y, alive) ->
		x = x * @kCellWidth
		y = y * @kCellHeight
		@ctx.fillStyle = rcolors[alive]
#		console.log "setRegion alive "+alive+" fill style "+@ctx.fillStyle
		@ctx.fillRect ~~x, ~~y, @kCellWidth, @kCellHeight
		

	count_neighbors: (row,col) ->
#		console.log "COUNT_NEIGHBORS row,col "+row+","+col if row == 8
		result = @count_neighbor row - 1,col - 1
#		console.log "-1,-1 "+result+ "grid of -1,-1 "+@grid[row-1][col-1] if row == 8
		result += @count_neighbor row - 1,col
#		console.log "-1,0 "+result if row == 8
		result += @count_neighbor row - 1,col + 1
#		console.log "-1,+1 "+result if row == 8
		result += @count_neighbor row,col - 1
#		console.log "0,-1 "+result if row == 8
		result += @count_neighbor row,col + 1
#		console.log "0,+1 "+result if row == 8
		result += @count_neighbor row + 1,col - 1
#		console.log "+1,-1 "+result if row == 8
		result += @count_neighbor row + 1,col
#		console.log "+1,0 "+result if row == 8
		result += @count_neighbor row + 1,col + 1
#		console.log "+1,+1 "+result if row == 8
		result

	count_neighbor: (row,col) ->
#		console.log "	count_neighbor row,col "+row+","+col if row == 7 or row==8 or row==9
		#mirror wrap
		if col < 0
			col = @ngridx - 1
		else if col >= @ngridx
			col = 0 
		if row < 0
			row = @ngridy - 1
		else if row >= @ngridy
			row = 0 
#		console.log "	count_neighbor row,col "+row+","+col+" val "+@grid[row][col] if row == 7 or row==8 or row==9
#		console.log "	count_neighbor sanity check @grid[7][5] "+@grid[7][5] if row == 7 or row==8 or row==9
		@grid[row][col]	

	live_or_die: (row,col) ->
		sum = @count_neighbors(row,col)
		alive = @grid[row][col]
		if sum < 2 or sum > 3
			alive = 0
		else if sum == 3
			alive = 1
#		console.log "live or die after setting alive, row col "+row+","+col+" alive "+alive+ " sum "+sum
		@newgrid[row][col] = alive
		return


	displayGrid: () ->
		console.log "in displayGrid"
		i=0
		while i < @ngridy
			j=0
			while j < @ngridx
				@setRegion j,i,@grid[i][j]
				j++
			i++
		@drawGrid()	
		return

	copyGrid: (destination, source) ->
		i=0
		while i < @ngridy
			j=0
			while j < @ngridx
				destination[i][j] = source[i][j]
				j++
			i++
		

	update: (playpause=1) ->
#		console.log "playpause passed "+playpause+" @playpause "+@playpause
		#jk dual flip flop flashback
		if playpause == @playpause
			@playpause = 0
			clearTimeout @time_out_id if @time_out_id 
		else 
			@playpause = 1
			
#		console.log "internal @playpause "+@playpause	
		if @playpause > 0
			console.log "in update grid of 7,5 "+@grid[7][5]
			i=0
			while i < @ngridy
				j=0
				while j < @ngridx
					@live_or_die i,j
					@setRegion j,i,@newgrid[i][j]
					j++
				i++
			@drawGrid()	
			@copyGrid(@grid,@newgrid)
			# the fat arrow on the setTimeout call took a bit to figure out
			@time_out_id = setTimeout( => 
				@update(2)
				500)
		return
#	window.update = @update	

	clear: () ->
		console.log "in clear"
		i=0
		while i < @ngridy
			j=0
			while j < @ngridx
				@newgrid[i][j]=0
				@setRegion j,i,0
				j++
			i++
		@copyGrid(@grid,@newgrid)	
		@drawGrid()
		return

	random: () ->
		i=0
		while i < @ngridy
			j=0
			while j < @ngridx
				@grid[i][j] = if Math.random() > .5 then 1 else 0
				j++
			i++
		@clear()
		@grid[7][5] = 1
		@grid[7][6] = 1
		@grid[7][7] = 1
		@grid[6][7] = 1
		@grid[5][6] = 1
		console.log "finished random"

	getMouseLocation: (e) ->
		console.log "GameOfLife getMouseLocation canvas "+@canvas
		x = y = null
		if e.pageX != undefined and e.pageY != undefined
			x = e.pageX
			y = e.pageY
		else
			x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
			y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
		x -= @canvas.offsetLeft
		y -= @canvas.offsetTop
		x = Math.min x, @width
		y = Math.min y, @height		
		x = Math.floor x / @kCellWidth
		y = Math.floor y / @kCellHeight
		@mouseDown = true
		console.log "  x y "+x+","+y
		return [x,y]

	onMouseDown: (e) ->
		[x,y] = @getMouseLocation(e)


	onMouseMove: (e) ->
		[x,y] = @getMouseLocation(e)
#		if ctx = @canvas.getContext
#			ctx.strokeStyle = "rgb(255,150,150)"
#			ctx.beginPath()
#			ctx.moveTo canvasX - 10, canvasY + 0.5
#			ctx.lineTo canvasX + 10, canvasY + 0.5
#			ctx.moveTo canvasX + 0.5, canvasY - 10
#			ctx.lineTo canvasX + 0.5, canvasY + 10
#			ctx.stroke()

	onMouseUp: (e) ->
		@mouseDown = false


window.GameOfLife = GameOfLife

