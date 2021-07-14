package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curSide:String = '';
	var curCharacter:String = '';

	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), FlxColor.BLACK);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		box.frames = Paths.getSparrowAtlas('dialogue/normal-dialogueBox');
		box.setGraphicSize(Std.int(box.width / 4));
		box.updateHitbox();
		box.animation.addByPrefix('normalOpen', 'spawn', 24, false);
		box.animation.addByIndices('normal', 'spawn', [11], "", 24);
		box.antialiasing = true;

		this.dialogueList = CoolUtil.coolTextFile(Paths.txt(PlayState.SONG.song.toLowerCase() + "/dialogue"));
		
		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.frames = Paths.getSparrowAtlas('dialogue/bf-portrait');
		portraitLeft.animation.addByPrefix('enter', 'portrait', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width / 4));
		portraitLeft.updateHitbox();

		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;
		portraitLeft.antialiasing = true;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf-portrait');
		portraitRight.animation.addByPrefix('enter', 'portrait', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width / 4));
		portraitRight.updateHitbox();

		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
		portraitRight.antialiasing = true;
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = FlxColor.BLACK;
		swagDialogue.sounds = [];
		add(swagDialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curSide)
		{
			case 'dad':
				portraitRight.visible = false;
				
				if (!portraitLeft.visible)
					portraitLeft.visible = true;

				box.flipX = false;
			case 'bf':
				portraitLeft.visible = false;

				if (!portraitRight.visible)
					portraitRight.visible = true;

				box.flipX = true;
		}

		portraits();

		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('text/' + curCharacter), 1)];
		portraitLeft.animation.play('enter');
		portraitRight.animation.play('enter');
	}

	function portraits()
	{
		var selectedPortrait:FlxSprite;

		if(portraitRight.visible)
			selectedPortrait = portraitRight;
		else
			selectedPortrait = portraitLeft;

		if(curCharacter == null)
			curCharacter = "nobody";

		selectedPortrait.frames = Paths.getSparrowAtlas('dialogue/' + curCharacter + '-portrait');
		selectedPortrait.animation.addByPrefix('enter', 'portrait', 24, false);
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curSide = splitName[1];
		curCharacter = splitName[3];
		dialogueList[0] = splitName[2].trim();

		if(splitName[4] != null)
		{
			if(curSide == "dad")
				PlayState.dad.animation.play(splitName[4], true);
			else
				PlayState.boyfriend.animation.play(splitName[4], true);
		}
		else
		{
			PlayState.dad.animation.play("idle", false);
			PlayState.boyfriend.animation.play("idle", false);
		}
	}
}
