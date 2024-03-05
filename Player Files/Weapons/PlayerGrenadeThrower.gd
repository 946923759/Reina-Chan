class_name PlayerGrenadeThrower

# TODO: Could have the caller pass in a refernced scene instead.
# Turning this into a generic weapon shooter.
var grenadeScene = preload("res://Player Files/Weapons/PlayerGrenade.tscn");


#Timer, if timer is < 0 then no throw
var currentCooldownTimer: float;
#Total duration (default: 1.5)
var cooldownDuration: float;

var bulletHolderReference: Node2D;

func _init(cooldownDuration: float, bulletHolderReference: Node2D):
	currentCooldownTimer = 0.0;
	self.cooldownDuration = cooldownDuration;
	self.bulletHolderReference = bulletHolderReference;
	pass

func isReadyToThrow() -> bool:
	return currentCooldownTimer >= cooldownDuration/3.0;
	
#For weapon meter
#TODO: SCALE() isn't even needed for this, is it?
# static func SCALE(x:float, l1:float, h1:float, l2:float, h2:float)->float:

# Returns a float within the range of 0.0 to 1.0
func getCooldownPercent() -> float:
	#return 1.0
	#return 0.5;
	return Def.SCALE(currentCooldownTimer, 0.0, cooldownDuration, 0.0, 1.0)
	
func update(deltaTime: float) -> void:
	if (currentCooldownTimer < cooldownDuration):
		currentCooldownTimer += deltaTime;
		
## Creates a grenade at the given position, with the facing direction.
## Returns: The grenade instance, null if the grenade cant be thrown due to cooldown.
func tryThrowGrenade(startPosition: Vector2, spriteDirection: float, rapidFire:bool = false) -> Node2D:
	if (!rapidFire and !isReadyToThrow()):
		return null
		
	currentCooldownTimer = max(currentCooldownTimer-cooldownDuration/3.0, 0.0);
	#print(currentCooldownTimer)
	
	var grenadeInstance = grenadeScene.instance();
	grenadeInstance.position = startPosition;
	# TODO: Should the caller handle initalizing the grenade instead?
	bulletHolderReference.add_child(grenadeInstance);
	grenadeInstance.init(spriteDirection);
	
	return grenadeInstance;
