extends Control
tool

export(String) var text = "???" setget set_text
export(String, FILE, "*.tscn") var destination_stage
export(Texture) var portrait_texture setget set_texture
export(bool) var show_texture = true setget set_show_texture

var time:float = 0.0

func _ready():
	set_process(false)
	#$TextureRect.visible = show_texture

func set_show_texture(b:bool):
	show_texture = b
	$TextureRect.visible = show_texture

func set_text(t:String):
	text=t
	$BitmapFont.text = text

func set_texture(tex:Texture):
	portrait_texture = tex
	$TextureRect.texture = tex

func GainFocus():
	time = 0.0
	set_process(true)
	
func LoseFocus():
	$Frame2.visible = false
	set_process(false)

func _process(delta):
	time+=delta*2.0
	$Frame2.visible = time < .5
	if time > 1.0:
		time -= 1.0
