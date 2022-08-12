extends Node2D

export(int) var fall_height = 14
const fallSpeed:float = 1000.0
#const waitBetweenFalling
#export var fallSpeed()
#onready var startYPos = self.position.y
#func _ready():

onready var rock = $StaticBody2D
func _process(delta):
	rock.position.y+=fallSpeed*delta
	if rock.position.y > position.y+fall_height*64:
		rock.position.y=0


func _on_StaticBody2D_body_entered(body):
	if body.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		body.call("player_touched",self,1)
