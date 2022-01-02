class_name Def
extends Node

const smSprite = preload("res://stepmania-compat/smSprite.gd")
const smQuad = preload("res://stepmania-compat/smQuad.gd")

func BitmapText(d)->Label:
	var l = Label.new()
	for property in d:
		l.set(property,d[property])
	#l.set("custom_fonts/font",font)
	return l
	
func LoadFont(font,d)->Label:
	var l = Label.new()
	for property in d:
		l.set(property,d[property])
	l.set("custom_fonts/font",font)
	return l
	
static func Quad(d)->smQuad:
	var q = smQuad.new()
	for property in d:
		if property=="size":
			q.setSize(d[property])
		else:
			q.set(property,d[property])
	return q
	
static func Sprite(d)->smSprite:
	var s = smSprite.new()
	for property in d:
		if property=="Texture":
			s.loadVNBG(d[property])
		elif property=="TextureFromDisk":
			s.loadFromExternal(d[property])
		elif property=="cover":
			s.Cover()
		else:
			s.set(property,d[property])
	return s
