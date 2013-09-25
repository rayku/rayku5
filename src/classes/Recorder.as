package classes
{
	[Bindable] public class Recorder
	{
		public var maxLength:int=90;
		public var fileName:String="1";
		public var width:int=320;
		public var height:int=240;
		public var server:String="rtmp://mathcentre.rayku.com:80/live/whiteboard/Tutor";
		public var fps:int=15;
		public var microRate:int=22;
		public var showVolume:Boolean=true;
		public var recordingText:String="Recording...";
		public var timeLeftText:String="Time Left:";
		public var timeLeft:int;
		public var mode:String="recorder";
		public var hasRecorded:Boolean=false;
		public var backToRecorder:Boolean=true;
		public var backText:String="Back";
		public var cameraDetected:Boolean=false;
		public var live:Boolean=true;
		
		public function Recorder()
		{	timeLeft = maxLength;
			mode="recorder";
			/*this.maxLength = maxLength;
			this.fileName = fileName;
			this.width = width;
			this.height = height;
			this.server = server;*/
		}

	}
}