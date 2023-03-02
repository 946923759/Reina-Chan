class_name PlayerGrenadeThrower

# TODO: Could have the caller pass in a refernced scene instead.
# Turning this into a generic weapon shooter.
var grenadeScene = preload("res://Player Files/Weapons/PlayerGrenade.tscn");

var currentCooldownTimer: float;
var cooldownDuration: float;

var bulletHolderReference: Node2D;

func _init(cooldownDuration: float, bulletHolderReference: Node2D):
	currentCooldownTimer = 0.0;
	self.cooldownDuration = cooldownDuration;
	self.bulletHolderReference = bulletHolderReference;
	pass

func isReadyToThrow() -> bool:
	return currentCooldownTimer <= 0.0;
	
#For weapon meter
#TODO: SCALE() isn't even needed for this, is it?
func getCooldownPercent() -> float:
	return Def.SCALE(cooldownDuration-currentCooldownTimer,0,cooldownDuration,0,1)
	
func update(deltaTime: float) -> void:
	if (currentCooldownTimer > 0.0):
		currentCooldownTimer -= deltaTime;
		
## Creates a grenade at the given position, with the facing direction.
## Returns: The grenade instance, null if the grenade cant be thrown due to cooldown.
func tryThrowGrenade(startPosition: Vector2, spriteDirection: float) -> Node2D:
	if (!isReadyToThrow()):
		return null
		
	currentCooldownTimer = cooldownDuration;
	
	var grenadeInstance = grenadeScene.instance();
	grenadeInstance.position = startPosition;
	# TODO: Should the caller handle initalizing the grenade instead?
	bulletHolderReference.add_child(grenadeInstance);
	grenadeInstance.init(spriteDirection);
	
	return grenadeInstance;
