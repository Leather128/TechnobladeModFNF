package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('dad', [2, 3], 0, false, isPlayer);
		animation.add('gf', [4], 0, false, isPlayer);
		animation.add('technoblade', [5, 6], 0, false, isPlayer);
		animation.add('technoblade-mad', [7, 8], 0, false, isPlayer);
		animation.add('technoblade-angry', [9, 10], 0, false, isPlayer);

		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
