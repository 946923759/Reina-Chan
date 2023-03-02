class_name Def
extends Node

const smSprite = preload("res://stepmania-compat/smSprite.gd")
const smQuad = preload("res://stepmania-compat/smQuad.gd")

static func BitmapText(d)->Label:
	var l = Label.new()
	for property in d:
		l.set(property,d[property])
	#l.set("custom_fonts/font",font)
	return l
	
static func LoadFont(font,d)->Label:
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

#//Stolen from RageUtil
#/**
# * @brief Scales x so that l1 corresponds to l2 and h1 corresponds to h2.
# *
# * This does not modify x, so it MUST assign the result to something!
# * Do the multiply before the divide to that integer scales have more precision.
# *
# * One such example: SCALE(x, 0, 1, L, H); interpolate between L and H.
# */
static func SCALE(x:float, l1:float, h1:float, l2:float, h2:float)->float:
	return (((x) - (l1)) * ((h2) - (l2)) / ((h1) - (l1)) + (l2))
