cell_width = 4
cell_height = 4
width = 96
height = 96
delay = 1
life = new Array(width)
all_td = null

running = false
threads = 0
request_stop = false
paused = false



get_element_by_id = (name) ->
	document.getElementById name

class Cell
	constructor: (@age=0,@old_age=1,@neighbours=0) ->	

	
SetCellImage = (x, y) ->
	v = life[x][y].age
	table_cell = all_td[x + width * y]
	if v == 0
		table_cell.style.background = "#E0E0E0"
	else
		table_cell.style.background = "#000000"
		
count_all_neighbours = ->
	x = 0
	while x < width
		life[x][0].neighbours = count_neighbours(x, 0)
		life[x][height - 1].neighbours = count_neighbours(x, height - 1)
		x++
	y = 1
	while y < height - 1
		life[0][y].neighbours = count_neighbours(0, y)
		life[width - 1][y].neighbours = count_neighbours(width - 1, y)
		y++
	x = 1
	while x < width - 1
		y = 1
		while y < height - 1
			life[x][y].neighbours = count_neighbours(x, y)
			y++
		x++
		
count_neighbours = (x, y) ->
	result = 0
	checkx = x - 1
	while checkx <= x + 1
		checky = y - 1
		while checky <= y + 1
			cx = (if (checkx < 0) then width - 1 else (if (checkx >= width) then 0 else checkx))
			cy = (if (checky < 0) then height - 1 else (if (checky >= height) then 0 else checky))
			result += life[cx][cy].age	if (cx != x) or (cy != y)
			checky++
		checkx++
	result
	
count_neighbours_fast = (x, y) ->
	result = life[x - 1][y - 1].age
	result += life[x - 1][y].age
	result += life[x - 1][y + 1].age
	result += life[x][y - 1].age
	result += life[x][y + 1].age
	result += life[x + 1][y - 1].age
	result += life[x + 1][y].age
	result += life[x + 1][y + 1].age
	result
	
update_neighbour_counts = (x, y, delta) ->
	update_neighbour_count x - 1, y - 1, delta
	update_neighbour_count x - 1, y, delta
	update_neighbour_count x - 1, y + 1, delta
	update_neighbour_count x, y - 1, delta
	update_neighbour_count x, y + 1, delta
	update_neighbour_count x + 1, y - 1, delta
	update_neighbour_count x + 1, y, delta
	update_neighbour_count x + 1, y + 1, delta
	
update_neighbour_count = (x, y, delta) ->
	if x < 0
		x = width - 1
	else x = 0	if x >= width
	if y < 0
		y = height - 1
	else y = 0	if y >= height
	current = life[x][y]
	current.neighbours = current.neighbours + delta
	
update_all = ->
	x = 0
	while x < width
		y = 0
		while y < height
			update x, y
			y++
		x++
		
update = (x, y) ->
	current = life[x][y]
	current.old_age = current.age
	if current.age == 0
		current.age = 1	if current.neighbours == 3
	else
		current.age = 0	if (current.neighbours > 3) or (current.neighbours < 2)
		
render_updated = ->
	x = 0
	while x < width
		y = 0
		while y < height
			current = life[x][y]
			unless current.old_age == current.age
				SetCellImage x, y
				update_neighbour_counts x, y, current.age - current.old_age
			y++
		x++
		
life_cycle = ->
	if running or (threads > 1)
		threads--
		return
	running = true
	update_all()
	render_updated()
	if request_stop
		request_stop = false
		threads--
	else
		setTimeout "life_cycle()", delay
	running = false
window.life_cycle = life_cycle
	
render_all = ->
	x = 0
	while x < width
		y = 0
		while y < height
			current = life[x][y]
			current.old_age = current.age ^ 1
			SetCellImage x, y
			y++
		x++
	count_all_neighbours()
	
life_setup = ->
	console.log "got into life setup ok"
	table = get_element_by_id("life_table")
#	table = $("#life_table").first()
	console.log "got element by id "+table
	x = 0
	while x < width
		life[x] = new Array(height)
		x++
	y = 0
	while y < height 
		row = "<tr>"
		x = 0
		while x < width 
			row = row+"<td style=\"background:#E0E0E0\" id=\"" + x + "\" name=\"" + y + "\"+ \" WIDTH=\"" + cell_width + "\" HEIGHT=\"" + cell_height + "><font size=\"-6\"></font></td>"
			life[x][y] = new Cell()
			x++
		row = row+"</tr>"
		$("#life_table").append row
		y++

	all_td = table.getElementsByTagName("td")
	console.log "got element by tag "+all_td
window.life_setup = life_setup

life_click = ->
	e = event.srcElement
	return	if e.id == "table"
	return	unless e.id?
	return	if e.id == ""
	x = eval(e.id)
	y = eval(e.name)
	current = life[x][y]
	current.age = 1
	SetCellImage x, y
	update_neighbour_counts x, y, current.age - current.old_age
window.life_click = life_click
	
life_clear = ->
	x = 0
	while x < width
		y = 0
		while y < height
			life[x][y].age = 0
			y++
		x++
	render_all()
	
life_randomise = ->
	x = 0
	while x < width
		y = 0
		while y < height
			if (life[x][y].age == 0) and (Math.floor(Math.random() * 5) == 0)
				life[x][y].age = 1
			else
				life[x][y].age = 0
			y++
		x++
	render_all()
window.life_randomise = life_randomise
	
life_pause = ->
	paused = not paused
	
life_start = ->
	unless paused
		if threads < 1
			threads++
			count_all_neighbours()
			life_cycle()
		request_stop = false
window.life_start = life_start
		
life_stop = ->
	request_stop = true	unless paused
window.life_stop = life_stop


###
FPSCounter = (ctx) ->
	@t = new Date().getTime() / 1000.0
	@n = 0
	@fps = 0.0
	@draw = ->
		@n++
		if @n == 10
			@n = 0
			t = new Date().getTime() / 1000.0
			@fps = Math.round(100 / (t - @t)) / 10
			@t = t
		ctx.fillStyle = "white"
		ctx.fillText "FPS: " + @fps, 1, 15

window.Float32Array = Array unless window.Float32Array
WIDTH = 800
HEIGHT = 600
NPARTICLES = 10000
CELLSIZE = 20
CELLSIZE2 = CELLSIZE / 2
color_mode = 0

modeSwap = (newMode) ->
	color_mode = newMode
window.modeSwap = modeSwap	

canvas = document.getElementById("c")
screenRatio = 1.0
if navigator.userAgent.match(/iPad/i)
	WIDTH = 320
	HEIGHT = 240
	NPARTICLES /= 5
	screenRatio = WIDTH / 640
	canvas.style.width = "640px"
	canvas.style.height = "480px"
	document.getElementById("d").style.width = canvas.style.width
	document.getElementById("d").style["margin-top"] = "30px"
	document.getElementById("h").style.display = "none"
else if navigator.userAgent.match(/iPhone|iPod|Android/i)
	WIDTH = 320
	HEIGHT = 200
	NPARTICLES /= 5
	screenRatio = WIDTH / window.innerWidth
	canvas.style.width = "100%"
	canvas.style.height = innerHeight + "px"
	document.getElementById("d").style.width = canvas.style.width
	document.getElementById("d").style.border = 0
	document.getElementById("h").style.display = "none"
	document.getElementById("header").style.display = "none"
	if navigator.userAgent.match(/Android/i)
		canvas.style.height = "1000px"
		setTimeout ->
			window.scrollTo 0, window.innerHeight
			setTimeout ->
				canvas.style.height = document.documentElement.clientHeight + "px"
			, 1
		, 100
ctx = canvas.getContext("2d")
particles = new Float32Array(NPARTICLES * 4)
flow = new Float32Array(WIDTH * HEIGHT / CELLSIZE / CELLSIZE * 2)

CELLS_X = WIDTH / 20
floor = Math.floor

i=0
while i < particles.length
	particles[i++] = Math.random() * WIDTH
	particles[i++] = Math.random() * HEIGHT
	particles[i++] = 0
	particles[i++] = 0

i = 0
while i < flow.length
	flow[i] = 0
	i++

start = 
	x: 0
	y: 0

down = true
canvas.onmousedown = (e) ->
	start.x = (e.clientX - canvas.offsetLeft) * screenRatio
	start.y = e.clientY - canvas.offsetTop * screenRatio
	down = true

canvas.ontouchstart = (e) ->
	canvas.onmousedown e.touches[0]
	false

canvas.onmouseup = canvas.ontouchend = ->
	down = false

canvas.ontouchmove = (e) ->
	canvas.onmousemove e.touches[0]

canvas.onmousemove = (e) ->
	mx = (e.clientX - canvas.offsetLeft) * screenRatio
	my = (e.clientY - canvas.offsetTop) * screenRatio
	return	if not down or mx == start.x and my == start.y
	ai = (floor(mx / CELLSIZE) + floor(my / CELLSIZE) * floor(WIDTH / CELLSIZE)) * 2
	flow[ai] += (mx - start.x) * 0.4
	flow[ai + 1] += (my - start.y) * 0.4
	start.x = mx
	start.y = my

# rcolors = ["rgba(255,0,0,0.8)","rgba(255,255,255,0.8)","rgba(255,255,0,0.8)"]
colors1 = ["rgba(30,30,100,0.8)","rgba(40,40,120,0.8)","rgba(60,60,140,0.8)","rgba(80,80,160,0.8)","rgba(100,100,180,0.8)","rgba(100,100,210,0.8)","rgba(100,100,230,0.8)"]
colors2 = ["rgba(220,0,0,0.8)","rgba(220,100,0,0.8)","rgba(220,220,180,0.8)","rgba(0,220,0,0.8)","rgba(0,0,220,0.8)","rgba(100,0,180,0.8)","rgba(220,60,220,0.8)"]

setInterval ->
	vd = 0.95
	ad = 0.95
	ar = 0.004
	w1 = WIDTH - 1
	ctx.fillStyle = "rgba(0, 0, 0, 0.6)"
	ctx.globalCompositeOperation = "source-over"
	ctx.fillRect 0, 0, WIDTH, HEIGHT
	ctx.globalCompositeOperation = "lighter"
	i = 0
	l = particles.length

	#fixed color
	if color_mode == 0 
		ctx.fillStyle = "rgba(120,120,255,0.8)"
	else if color_mode == 1
		useColors = colors1
	else 
		useColors = colors2

	while i < l
		x  = particles[i]
		y  = particles[i + 1]
		vx = particles[i + 2]
		vy = particles[i + 3]
		ai = (~~(x / CELLSIZE) + ~~(y / CELLSIZE) * CELLS_X) * 2
		ax = flow[ai]
		ay = flow[ai + 1]
		ax = (ax + vx * ar) * ad
		ay = (ay + vy * ar) * ad
		vx = (vx + ax) * vd
		vy = (vy + ay) * vd


		#random colors
		#v1 = vx*vx + vy*vy 
#		if v1 < 1
#			ctx.fillStyle = "rgba("+~~(Math.random()*100+80)+","+~~(Math.random()*100+80)+","+~~(Math.random()*175+80)+",0.8)"
#		else
#			ctx.fillStyle = rcolors[~~(Math.random()*rcolors.length)]

		if color_mode > 0
			# velocity based colors
			v1 = vx*vx + vy*vy 
			if v1 < 1
				ctx.fillStyle = useColors[~~(Math.random()*useColors.length)]
			else if v1 < 4
				ctx.fillStyle = useColors[0]
			else if v1 < 9
				ctx.fillStyle = useColors[1]
			else if v1 < 16
				ctx.fillStyle = useColors[2]
			else if v1 < 25
				ctx.fillStyle = useColors[3]
			else if v1 < 36
				ctx.fillStyle = useColors[4]
			else if v1 < 64
				ctx.fillStyle = useColors[5]
			else
				ctx.fillStyle = useColors[6]
				
		x += vx
		y += vy
		ctx.fillRect ~~x, ~~y, 2, 2
		if x < 0
			vx *= -1
			x = 0
		else if x > w1
			x = w1
			vx *= -1
		if y < 0
			vy *= -1
			y = 0
		else if y > HEIGHT
			y = HEIGHT - 1
			vy *= -1
		particles[i] = x
		particles[i + 1] = y
		particles[i + 2] = vx
		particles[i + 3] = vy
		flow[ai] = ax
		flow[ai + 1] = ay
		i += 4
, 33
fps = new FPSCounter(ctx)
canvas.width = WIDTH
canvas.height = HEIGHT
###