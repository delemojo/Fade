package com.muzari.polskabot.fade
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import com.hurlant.math.BigInteger;
	import com.hurlant.crypto.rsa.RSAKey;
	import com.hurlant.crypto.prng.ARC4;
	import com.hurlant.util.Hex;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Pandora
	{
		public var importantBigInteger:BigInteger;
		public static const firstCode:BigInteger = new BigInteger("d58f6abf26e9cf6da93d694f05a304955ff9cb0ff07cf77a2b6cb43295d720abc0dcab4c0eb5caba33e7d9848c0a00271c7a340f320b36c764aaed84ba2bd32");
		public static const secondCode:BigInteger = new BigInteger("e9df18ce2d8109a32afd0093aef0d68270e494a32b1119a70e22a61f8464169f620f96aff5ea6ed6b8dae84baf007237c98fc165732f6025ac3065ebca4edfa9");
		
		protected var stageOne:Wrapper;
		protected var stageTwoEncode:RC4;
		protected var stageTwoDecode:RC4;
		
		protected var stageOneActive:Boolean;
		public var stageTwoActive:Boolean;
		
		public function Pandora()
		{
			stageOne = new Wrapper();
			stageTwoEncode = new RC4();
			stageTwoDecode = new RC4();
		}
		
		public function initStageOne(param1:ByteArray):void
		{
			this.stageOne.load(param1);
			stageOneActive = true;
		}
		
		public function generateObfuscationCallback():ByteArray
		{
			trace("Generating obfuscation callback");
			var _local_5:int;
			var _local_6:String;
			var _local_1:String = new String();
			for (var i:int = 0; i < 128; i++)
			{
				_local_5 = (Math.random() * 0x0100);
				_local_6 = _local_5.toString(16);
				if (_local_6.length == 1)
				{
					_local_6 = ("0" + _local_6);
				}
				;
				_local_1 = (_local_1 + _local_6);
			}
			;
			importantBigInteger = new BigInteger(_local_1, 16);
			var _local_3:BigInteger = firstCode.modPow(importantBigInteger, secondCode);
			var local3ToBytes:ByteArray = _local_3.toByteArray();
			trace("Obfuscation callback generated, size " + local3ToBytes.length);
			return local3ToBytes;
		}
		
		public function initStageTwo(param1:ByteArray):void
		{
			var _loc3_:ByteArray = null;
			var _loc4_:BigInteger = null;
			var _loc6_:BigInteger = null;
			var _loc7_:BigInteger = null;
			var secretKey:ByteArray = null;
			var _loc2_:RSAKey = new RSAKey(new BigInteger("84c16e0a5860d56409207e6b542f168de24e434198e68b363dec817b77a594a17f968f177e871bfd626d139099cb3af0070cf2a03b46d1404503dc95d5a72f7c61e36b61967be50bd6bdf8d3376171b00fce65c521bc3267cdf7e6b0c3d725c9"), 65537);
			try
			{
				_loc3_ = new ByteArray();
				_loc2_.verify(param1, _loc3_, param1.length);
				_loc3_.position = 0;
				_loc4_ = new BigInteger(_loc3_);
				_loc7_ = _loc4_.modPow(importantBigInteger, secondCode);
				secretKey = new ByteArray();
				_loc7_.toByteArray().readBytes(secretKey, 0, 16);
				stageTwoEncode.init(secretKey);
				stageTwoDecode.init(secretKey);
				stageTwoActive = true;
			}
			catch (error:Error)
			{
				trace(error);
			}
		}
		
		public function encode(param1:ByteArray):ByteArray
		{
			var out:ByteArray;
			if (stageTwoActive)
			{
				stageTwoEncode.encrypt(param1);
			}
			out = this.stageOne.encode(param1);
			return out;
		}
		
		public function decode(param1:ByteArray):ByteArray
		{
			var out:ByteArray = this.stageOne.decode(param1);
			if (stageTwoActive)
			{
				stageTwoDecode.decrypt(out);
			}
			return out;
		}
		
		public function getStageOne():Wrapper
		{
			return stageOne;
		}
	
	}

}
