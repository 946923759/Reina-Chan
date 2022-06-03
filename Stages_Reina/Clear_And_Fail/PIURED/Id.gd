#The most pointless class ever
class_name PIURED_ID

static func getId(kind:String, padId:int, i:int, j:int)->String:
	return kind + '-' + String(padId) + '-' + String(i) + '-' + String(j)
