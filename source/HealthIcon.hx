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
		
		loadGraphic(Paths.image('icons/' + char + '-icons'), true, 150, 150);

		antialiasing = true;

		animation.add(char, [0, 1, 2], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();
	}

	public function resetNew(char:String = 'bf', isPlayer:Bool = false)
	{
		animation.destroyAnimations();
		
		loadGraphic(Paths.image('icons/' + char + '-icons'), true, 150, 150);

		animation.add(char, [0, 1, 2], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
