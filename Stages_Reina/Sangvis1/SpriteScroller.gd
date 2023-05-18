extends Sprite

export (float,-15,15,.2) var x_scroll = 0
export (float,-15,15,.2) var y_scroll = 10
export (int) var x_limit = 16
export (int) var y_limit = 16

func _process(delta):
	self.region_rect.position.y +=delta*y_scroll*10
	if self.region_rect.position.y > y_limit:
		self.region_rect.position.y-=y_limit
		
	self.region_rect.position.x +=delta*x_scroll*10
	if self.region_rect.position.x > x_limit:
		self.region_rect.position.x-=x_limit
