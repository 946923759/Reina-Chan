extends Node
#I hate Godot's translation service
#I also hate Godot's non functioning ini parser
enum LanguageType {
	ASCII,
	ACCENTED,
	NON_LATIN
}

var currentLanguage:String="en"
var currentLanguageType:int = LanguageType.ASCII
var translation:Dictionary={}
var font:Font #No point in preloading it when it gets overwritten on init
#var font=preload("res://MM2Font.tres")

func GetLanguageDir()->String:
	match OS.get_name():
		"Windows","X11","macOS":
			if OS.has_feature("standalone"):
				return OS.get_executable_path().get_base_dir()+"/GameData/Languages/"
	return "res://Languages/"
#func initBaseLanguage():

func _getDictionary(path:String)->Dictionary:
	var f = File.new()
	var ok = f.open(path, File.READ)
	if ok != OK:
		printerr("Warning: could not open file for reading! ERROR ", ok)
		printerr(path)
		return Dictionary()
	var d = {'Common':{}}
	var lastCategory:String="Common"
	while !f.eof_reached():
		var line:String = f.get_line().strip_edges(false,true)
		if line.begins_with('['):
			lastCategory=line.substr(1,line.length()-2)
			#print(lastCategory)
			d[lastCategory]={}
		elif line.begins_with(";") or line.begins_with('#') or line.begins_with("'"):
			continue
		elif !line.empty():
			#print(line)
			var kv = line.split("=",true,1)
			#print(kv[1])
			d[lastCategory][kv[0]]=kv[1].replace("\\n","\n")
	f.close() #
	return d
		
func SetLanguage(lang:String)->bool:
	translation=_getDictionary(GetLanguageDir()+"en.ini")
	currentLanguage=lang
	print("Loaded base translation. There are "+String(translation.size())+" categories.")
	#print(translation)
	#print(GetString("TitleScreen","PLAY_INTRO"))
	#English is the base language, other languages are
	#added on top. This is so if a key is missing it will
	#silently fall back to English.
	#return true

	if lang!="en":
		var newTranslation:Dictionary=_getDictionary(GetLanguageDir()+lang+".ini")
		if newTranslation.size()==0:
			printerr("The translation file "+lang+" failed to load, WTF did you do???")
			return false
		for category in newTranslation.keys():
			#translation[category]={}
			for k in newTranslation[category].keys():
				translation[category][k]=newTranslation[category][k]
				#translation[category][k]=config.get_value()
	print("Loaded "+lang+" translation.")
	print(GetString("TitleScreen","START_GAME"))
	match lang:
		"en":
			font=load("res://ubuntu-font-family/MM2Font.tres")
			currentLanguageType=LanguageType.ASCII
		"es":
			font=load("res://ubuntu-font-family/FallbackPixelFont.tres")
			currentLanguageType=LanguageType.ACCENTED
		_:
			font=load("res://ubuntu-font-family/JP_KR_font.tres")
			currentLanguageType=LanguageType.NON_LATIN
	
	return true

func GetString(category:String,key:String,warn:bool=true)->String:
	if translation.size()==0:
		push_error("There is no translation loaded...")
		return key
	elif translation.has(category) and translation[category].has(key):
		return translation[category][key]
	if warn:
		push_warning("There is no translation for ["+category+"] "+key)
	return key

func GetStringOrNull(category:String,key:String)->String:
	if translation.size()==0:
		push_error("There is no translation loaded...")
		return ""
	elif translation.has(category) and translation[category].has(key):
		return translation[category][key]
	return ""
