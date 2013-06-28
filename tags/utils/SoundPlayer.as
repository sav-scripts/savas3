/*	a static class for sound playing 
 * 	for initalize it , give it a sound pack (array of Sounds index with string) by init() function
 */
package sav.utils
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;

	public class SoundPlayer
	{
		public static function init(soundPack:Object , ignoreMissSoundError:Boolean = false):void
		{		
			_soundPack = soundPack;
			_soundArray = [];
			_ignoreMissSoundError = ignoreMissSoundError;
		}
		
		// play a sound file as a BGM ( will be repeat and registed as a BGM , make it be effected when musicOn changed
		public static function playBGM(soundName:String, volume:Number = 1, fadeInDuration:Number = 0, overrideSameSound:Boolean = false):Object
		{
			if (checkSound(soundName) == false) return null;
			
			if (overrideSameSound == false) 
			{
				if (hasSound(soundName)) 
				{
					return null;
				}
			}
			var object:Object = playSound(soundName , volume, 99999, fadeInDuration, true);
			
			return object;			
		}
		
		// play a sound 
		public static function playSound(soundName:String, volume:Number = 1, repeats:uint = 0, fadeInDuration:Number = 0, isBGM:Boolean = false, delay:Number = 0):Object
		{	
			if (checkSound(soundName) == false) return null;
			
			var oldVolume:Number	= volume;
			
			var object:Object		= {};
			if (isBGM)
			{
				volume = (musicOn) ? volume : 0;
			}
			else
			{
				volume = (soundOn) ? volume : 0;
			}

			var soundTransform	:SoundTransform		= new SoundTransform(volume);
			var soundChannel:SoundChannel			= new SoundChannel();
			object.soundName						= soundName;
			object.sound							= _soundPack[soundName];
			object.volume							= volume;
			object.oldVolume						= oldVolume;
			object.isBGM							= isBGM;
			
			if (delay == 0)
			{
				soundChannel = object.sound.play(0 , repeats , soundTransform);
			}
			else
			{
				Tweener.addTween(object.sound , { time:delay , onComplete:playDelayedSound , onCompleteParams:[object.sound , 0 , repeats , soundTransform] } );				
			}
			
			if (fadeInDuration > 0)
			{
				object.volume = 0;
				Tweener.addTween(object , { time:fadeInDuration , volume:volume, transition:'linear', onUpdate:soundVolumeUpdate , onUpdateParams:[object] } );
			}
			
			
			soundChannel.addEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);
			object.soundChannel		= soundChannel;
			
			_soundArray.push(object);
			
			return object;			
		}
		
		private static function playDelayedSound(sound:Sound , startTime:Number , repeats:uint  , soundTransform:SoundTransform):void
		{
			sound.play(startTime , repeats , soundTransform);
		}
		
		// check if this soundName exist in _soundPack
		private static function checkSound(soundName:String):Boolean
		{
			if (!_soundPack[soundName])
			{
				if (_ignoreMissSoundError == false)
				{
					throw new Error('Sound ' + soundName + ' cound not be found.');
				}
				return false;
			}
			else
			{
				return true;
			}			
		}
		
		// remove .... sound .... by .... name
		public static function removeSoundByName(soundName:String , removeAll:Boolean = true):void
		{
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];
				if (object.soundName == soundName)
				{
					object.soundChannel.stop();
					object.soundChannel.removeEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);
					_soundArray.splice(i,1);
					i--;
					if(removeAll == false) break;
				}
			}
		}
		
		// if there is sound with same name playing 
		public static function hasSound(soundName:String):Boolean
		{
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];
				if (object.soundName == soundName)
				{
					return true;
				}
			}
			return false;

		}
		
		public static function changeVolume(soundName:String, volume:Number, duration:Number = 0):void
		{
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];
				if (object.soundName == soundName)
				{
					Tweener.removeTweens(object);
					if (duration > 0)
					{
						Tweener.removeTweens(object);
						Tweener.addTween(object , { time:duration , volume:volume , onUpdate:soundVolumeUpdate, transition:'linear', onUpdateParams:[object] } );
					}
					else
					{
						object.volume = volume;
						soundVolumeUpdate(object);
					}
					
				}
			}
		}
		
		// fade out sound by name , time mean how long it will be totally faded
		public static function fadeOutSoundByName(soundName:String , time:Number = 1):void
		{
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];
				if (object.soundName == soundName)
				{
					Tweener.removeTweens(object);
					Tweener.addTween(object , {time:time , volume:0 , onUpdate:soundVolumeUpdate, transition:'linear', onUpdateParams:[object] , onComplete:soundFadeComplete , onCompleteParams:[object]});
				}
			}
		}
		
		private static function soundVolumeUpdate(object:Object):void
		{
			var soundTransform:SoundTransform = new SoundTransform(object.volume);
			object.soundChannel.soundTransform = soundTransform;
		}
		
		private static function soundFadeComplete(object:Object):void
		{
			object.soundChannel.stop();
			object.soundChannel.removeEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);
			var index:int = _soundArray.indexOf(object);
			_soundArray.splice(index , 1);
		}
		
		private static function soundCompleteHandler(evt:Event):void
		{
			evt.target.removeEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);
			
			for (var i:uint=0 ; i<_soundArray.length ; i++) 
			{
				var object:Object = _soundArray[i];
				if (object.soundChannel == evt.target)
				{
					_soundArray.splice(i,1);
					break;
				}
			}
		}
		
		public static function get soundOn():Boolean
		{
			return _soundOn;
		}
		
		// turn sound effect on or off
		public static function set soundOn(boolean:Boolean):void
		{
			_soundOn = boolean;
			var soundTransform:SoundTransform , object:Object;
			if (_soundOn == false)
			{
				for each(object in _soundArray)
				{
					if (object.isBGM == false)
					{
						soundTransform = new SoundTransform(0);
						object.soundChannel.soundTransform = soundTransform;						
					}
				}
			}
			else
			{
				for each(object in _soundArray)
				{
					if (object.isBGM == false)
					{
						soundTransform = new SoundTransform(object.oldVolume);
						object.soundChannel.soundTransform = soundTransform;						
					}
				}
			}
		}
		
		// turn music effect on or off
		public static function get musicOn():Boolean
		{
			return _musicOn;
		}
		
		public static function set musicOn(boolean:Boolean):void
		{
			_musicOn = boolean;
			var soundTransform:SoundTransform , object:Object;
			if (_musicOn == false)
			{
				for each(object in _soundArray)
				{
					if (object.isBGM == true)
					{
						soundTransform = new SoundTransform(0);
						object.soundChannel.soundTransform = soundTransform;						
					}
				}
			}
			else
			{
				for each(object in _soundArray)
				{
					if (object.isBGM == true)
					{
						soundTransform = new SoundTransform(object.oldVolume);
						object.soundChannel.soundTransform = soundTransform;						
					}
				}
			}
		}
		
		/*********************
		 * 		 params
		 * ******************/
		private static var _soundPack			:Object;			// raw data of Sound Class store here
		private static var _soundArray			:Array;				// all playing sound's data store here
		
		private static var _soundOn				:Boolean = true;	// sound effect option
		private static var _musicOn				:Boolean = true;	// music(BGM) option
		private static var _mute				:Boolean = false;	// turn this to true will close both sound effect and music
		public static function get mute():Boolean { return _mute; }
		public static function set mute(b:Boolean):void { _mute = b; soundOn = (b == false); musicOn = (b == false); }
		
		public static var _ignoreMissSoundError	:Boolean = false;	// should we ignore error when we can't Sound from _soundPack
	}
}