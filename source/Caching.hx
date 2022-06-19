package;

import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
    var toBeDone = 0;
    var done = 0;

    var text:FlxText;
    var kadeLogo:FlxSprite;

	override function create()
	{
        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);

        text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
        text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        text.borderSize = 1.5;

        kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('KadeEngineLogo'));
        kadeLogo.x -= kadeLogo.width / 2;
        kadeLogo.y -= kadeLogo.height / 2 + 100;
        text.y -= kadeLogo.height / 2 - 125;
        text.x -= 170;
        kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));

        kadeLogo.alpha = 0;

        var bg = new FlxSprite().loadGraphic(openfl.display.BitmapData.fromFile(FileSystem.absolutePath("assets/technoWeek1/images/lmanburg/sky-in-terms-of-atmosphere-sky-and-not-the-fangirl.png")));
        bg.screenCenter();
        bg.alpha = 0.75;

        add(bg);
        add(kadeLogo);
        add(text);

        trace('starting caching..');
        
        sys.thread.Thread.create(() -> {
            cache();
        });

        super.create();
    }

    var calledDone = false;

    override function update(elapsed) 
    {
        if(done != 0 && toBeDone != 0)
            kadeLogo.alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;

        text.text = "Loading... (" + done + "/" + toBeDone + ")";
        text.screenCenter(X);

        super.update(elapsed);
    }

    public static var images:Array<String> = [];
    public static var music:Array<String> = [];

    public static var graphics:Array<flixel.graphics.FlxGraphic> = [];
    public static var sounds:Array<flixel.system.FlxSound> = [];

    function cache()
    {
        trace("caching images...");
        cacheDirectory("assets/images", ".png", images);

        trace("caching shared/images...");
        cacheDirectory("assets/shared/images", ".png", images);

        trace("caching technoWeek1/images...");
        cacheDirectory("assets/technoWeek1/images", ".png", images);

        trace("caching technoWeek2/images...");
        cacheDirectory("assets/technoWeek2/images", ".png", images);

        trace("caching music...");
        cacheDirectory("assets/music", ".ogg", music);

        trace("caching songs...");
        cacheDirectory("assets/songs", ".ogg", music);

        trace("caching technoWeek1/sounds...");
        cacheDirectory("assets/technoWeek1/sounds", ".ogg", music);

        toBeDone = Lambda.count(images) + Lambda.count(music);

        trace("LOADING: " + toBeDone + " OBJECTS.");

        for (i in images)
        {
            var bitmap = openfl.display.BitmapData.fromFile(FileSystem.absolutePath(i));

            var graphic = FlxG.bitmap.add(bitmap);
            graphic.persist = true;
            graphics.push(graphic);

            trace("cached " + i + " [" + done + "]");

            done++;
        }

        for (i in music)
        {
            var sound = openfl.media.Sound.fromFile(FileSystem.absolutePath(i));

            var sound = FlxG.sound.load(sound);
            sound.persist = true;
            sounds.push(sound);

            trace("cached " + i + " [" + done + "]");

            done++;
        }

        trace("Finished caching...");

        FlxG.switchState(new TitleState());
    }

    function cacheDirectory(relPath:String, fileExtension:String, array:Array<String>) {
        for (i in FileSystem.readDirectory(FileSystem.absolutePath(relPath)))
        {
            if(FileSystem.isDirectory(FileSystem.absolutePath(relPath + "/" + i)))
            {
                cacheDirectory(relPath + "/" + i, fileExtension, array);

                continue;
            }

            if (!i.endsWith(fileExtension))
                continue;
            
            array.push(relPath + "/" + i);
        }
    }
}