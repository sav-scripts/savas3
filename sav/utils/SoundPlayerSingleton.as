/**
 * ...
 * @author Sav
 */
package sav.utils
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.events.Event;
	
	import caurina.transitions.Tweener;

	public class SoundPlayerSingleton
	{
		/**********************
		 *     initializer
		 * *******************/
		public function init(ignoreMissSoundError:Boolean = false):void
		{		
			//if (_isInit) throw new Error("SoundPlayer already initialized");
			if (_isInit) return;
			
			_soundPack = {};
			_soundArray = [];
			_ignoreMissSoundError = ignoreMissSoundError;
			
			_isInit = true;
		}
		
		public function registSound(name:String, SoundClass:Class, defaultVolume:Number = 1):void
		{
			if (!_isInit) throw new Error("SoundPlayer not initialized");
			if (_soundPack[name]) trace("Warning : sound name [" + name + "] already registed");
			
			_soundPack[name] = { sound:new SoundClass(), defaultVolume:defaultVolume };
		}
		
		
		/**************************
		 *  primary play methods
		 * ***********************/
		public function playBGM(soundName:String, volume:Number = 1, fadeInDuration:Number = 0, overrideSameSound:Boolean = false):Object
		{
			if (!_isInit) throw new Error("SoundPlayer not initialized");
			if (checkSound(soundName) == false) return null;
			
			if (overrideSameSound == false) 
			{
				if (hasSound(soundName)) 
				{
					return null;
				}
			}
			var object:Object = playSound(soundName , volume, 999999, fadeInDuration, true);
			
			return object;			
		}
		
		public function playSound(soundName:String, volume:Number = 1, repeats:uint = 0, fadeInDuration:Number = 0, isBGM:Boolean = false, delay:Number = 0):Object
		{	
			if (!_isInit) throw new Error("SoundPlayer not initialized");
			if (checkSound(soundName) == false) return null;
			
			var soundObj:Object = _soundPack[soundName];
			volume = volume * soundObj.defaultVolume;
			
			var requestedVolume:Number	= volume;
			
			var object:Object		= {};
			if (isBGM)
			{
				volume = (musicOn) ? volume : 0;
			}
			else
			{
				volume = (soundOn) ? volume : 0;
			}
			
			var startVolume:Number = (fadeInDuration > 0) ? 0 : volume;
			

			var soundTransform:SoundTransform		= new SoundTransform(startVolume);
			var soundChannel:SoundChannel			= new SoundChannel();
			object.soundName						= soundName;
			object.sound							= soundObj.sound;
			object.volume							= volume;
			object.requestedVolume					= requestedVolume;
			object.isBGM							= isBGM;
			
			if (delay == 0)
			{
				soundChannel = object.sound.play(0 , repeats , soundTransform);
			}
			else
			{
				Tweener.addTween(object.sound , { time:delay , onComplete:playDelayedSound , onCompleteParams:[object , 0 , repeats , soundTransform] } );				
			}
			
			if (fadeInDuration > 0)
			{
				object.volume = 0;
				Tweener.addTween(object , { time:fadeInDuration , volume:volume, transition:'linear', onUpdate:soundVolumeUpdate , onUpdateParams:[object] } );
			}
			
			if (soundChannel) soundChannel.addEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);
			
			object.soundChannel	= soundChannel;			
			_soundArray.push(object);
			
			return object;			
		}
		
		private function playDelayedSound(object:Object , startTime:Number , repeats:uint  , soundTransform:SoundTransform):void
		{
			object.soundChannel = object.sound.play(startTime , repeats , soundTransform);
		}
		
		private function checkSound(soundName:String):Boolean
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
		
		public function hasSound(soundName:String):Boolean
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
		
		
		/**********************
		 *  remove and control
		 * *******************/
		public function removeAll():void
		{
			
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];				
				
				Tweener.removeTweens(object.sound);
				Tweener.removeTweens(object);
				
				if (object.soundChannel)
				{
					object.soundChannel.stop();
					object.soundChannel.removeEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);						
				}
			}
			_soundArray = [];
		}
		 
		public function removeSoundByName(soundName:String , removeAll:Boolean = true):void
		{
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];				
				
				if (object.soundName == soundName)
				{
					Tweener.removeTweens(object.sound);
					Tweener.removeTweens(object);
					
					if (object.soundChannel)
					{
						object.soundChannel.stop();
						object.soundChannel.removeEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);						
					}
					
					_soundArray.splice(i,1);
					i--;
					if(removeAll == false) break;
				}
			}
		}
		
		public function changeVolume(soundName:String, volume:Number, duration:Number = 0):void
		{
			var soundObj:Object = _soundPack[soundName];
			volume = volume * soundObj.defaultVolume;
			
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
		
		public function fadeOutSoundByName(soundName:String , time:Number = 1):void
		{
			for (var i:uint=0 ; i<_soundArray.length ; i++)
			{
				var object:Object = _soundArray[i];
				if (object.soundName == soundName)
				{
					Tweener.removeTweens(object.sound);
					Tweener.removeTweens(object);
					Tweener.addTween(object , {time:time , volume:0 , onUpdate:soundVolumeUpdate, transition:'linear', onUpdateParams:[object] , onComplete:soundFadeComplete , onCompleteParams:[object]});
				}
			}
		}
		
		private function soundVolumeUpdate(object:Object):void
		{
			if (!object.soundChannel) return;
			var soundTransform:SoundTransform = new SoundTransform(object.volume);
			object.soundChannel.soundTransform = soundTransform;
		}
		
		private function soundFadeComplete(object:Object):void
		{
			//trace('sound fade complete : ' + object.soundName);
			if (object.soundChannel)
			{
				object.soundChannel.stop();
				object.soundChannel.removeEventListener(Event.SOUND_COMPLETE , soundCompleteHandler);
			}
			var index:int = _soundArray.indexOf(object);
			_soundArray.splice(index , 1);
		}
		
		private function soundCompleteHandler(evt:Event):void
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
		
		
		
		/*********************
		 * 		 params
		 * ******************/
		private var _isInit:Boolean = false;
		 
		private var _soundPack:Object;
		public function get soundPack():Object { return _soundPack; }
		
		private var _soundArray:Array;
		
		private var _soundOn:Boolean = true;		
		public function get soundOn():Boolean { return _soundOn; }		
		public function set soundOn(boolean:Boolean):void
		{
			_soundOn = boolean;
			var soundTransform:SoundTransform , object:Object;
			if (_soundOn == false)
			{
				for each(object in _soundArray)
				{
					if (!object.soundChannel) continue;
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
					if (!object.soundChannel) continue;
					if (object.isBGM == false)
					{
						soundTransform = new SoundTransform(object.requestedVolume);
						object.soundChannel.soundTransform = soundTransform;						
					}
				}
			}
		}
		
		private var _musicOn:Boolean = true;	// music(BGM) option
		public function get musicOn():Boolean { return _musicOn; }		
		public function set musicOn(boolean:Boolean):void
		{
			_musicOn = boolean;
			var soundTransform:SoundTransform , object:Object;
			if (_musicOn == false)
			{
				for each(object in _soundArray)
				{
					if (!object.soundChannel) continue;
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
					if (!object.soundChannel) continue;
					if (object.isBGM == true)
					{
						soundTransform = new SoundTransform(object.requestedVolume);
						object.soundChannel.soundTransform = soundTransform;						
					}
				}
			}
		}
		
		private var _mute:Boolean = false;
		public function get mute():Boolean { return _mute; }
		public function set mute(b:Boolean):void { _mute = b; soundOn = (b == false); musicOn = (b == false); }
		
		public var _ignoreMissSoundError:Boolean = false;
	}
}