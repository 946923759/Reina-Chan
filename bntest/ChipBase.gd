extends Node

enum ELEMENT {
	normal,
	heat,
	aqua,
	eleki,
	leaf,
	poison,
	earth,
};

export (String) var chipName;
export (ELEMENT) var element=ELEMENT.normal;
export (int) var power = 0;
export (int) var subPower = 0;
export (int) var plusPower = 0;
#export (int) var regSize = 0;
export (int) var number = 0; #Unknown purpose
export (Array) var chipFolderCodes = ["*","*","*","*"]
export (bool) var darkChip = false
export (bool) var naviChip = false
"""
public bool printIcon = true;
public bool shadow = true;
public string[] information = new string[3];
public float sortNumber = -1f;
public Point rockOnPoint;
public bool infight;
public bool sideOnly;
public bool paralyze;
public bool _break;
public bool plusing;
public bool shild;
public bool obje;
public bool powerprint;
protected int flamesub;
public bool inviNo;
public bool chipUseEnd;
public bool crack;
public bool chargeFlag;
public int[] randomSeed;
private int randomSeedUse;
public const int manySeeds = 10;
public int userNum;
private int BlackOutFlame;
public bool blackOutInit;
private string blackOutName;
private string blackOutPower;
public bool blackOutLend;
"""
export (bool) var timeStopper = false;

"""
private bool boEndOK1;
private bool boEndOK2;
public string powertxt;
public int nameAlpha;
"""

func _init(pos:Vector2):
	if naviChip:
		timeStopper=true
		
#func paralyze():
	
