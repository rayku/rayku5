// ActionScript file
import classes.Recorder;

import components.gauge.events.GaugeEvent;

import flash.media.Camera;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.FlexGlobals;


NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF3;
SharedObject.defaultObjectEncoding  = flash.net.ObjectEncoding.AMF3;

public var nc:NetConnection;
public var ns:NetStream;					//
[Bindable] public var so_chat:SharedObject;
public var camera:Camera;
public var mic:Microphone;
public var nsOutGoing:NetStream;
public var nsInGoing:NetStream;
public const ROOMMODEL:String="models";
[Bindable] public var myRecorder:Recorder;
public var DEBUG:Boolean=false;
public var recordingTimer:Timer = new Timer( 1000 , 0 );
[Bindable] public var timeLeft:String="";



public function init():void {
	myRecorder = new Recorder();
	
	// get parameters
	if(FlexGlobals.topLevelApplication.parameters.maxLength!=null) myRecorder.maxLength= FlexGlobals.topLevelApplication.parameters.maxLength;
	if(FlexGlobals.topLevelApplication.parameters.fileName!=null) myRecorder.fileName = FlexGlobals.topLevelApplication.parameters.fileName;
	if(FlexGlobals.topLevelApplication.parameters.width!=null) myRecorder.width= FlexGlobals.topLevelApplication.parameters.width;
	if(FlexGlobals.topLevelApplication.parameters.height!=null) myRecorder.height= FlexGlobals.topLevelApplication.parameters.height;
	if(FlexGlobals.topLevelApplication.parameters.server!=null) myRecorder.server= FlexGlobals.topLevelApplication.parameters.server;
	if(FlexGlobals.topLevelApplication.parameters.fps!=null) myRecorder.fps= FlexGlobals.topLevelApplication.parameters.fps;
	if(FlexGlobals.topLevelApplication.parameters.microRate!=null) myRecorder.microRate= FlexGlobals.topLevelApplication.parameters.microRate;
	if(FlexGlobals.topLevelApplication.parameters.showVolume!=null) myRecorder.showVolume= FlexGlobals.topLevelApplication.parameters.showVolume;
	if(FlexGlobals.topLevelApplication.parameters.recordingText!=null) myRecorder.recordingText= FlexGlobals.topLevelApplication.parameters.recordingText;
	if(FlexGlobals.topLevelApplication.parameters.timeLeftText!=null) myRecorder.timeLeftText= FlexGlobals.topLevelApplication.parameters.timeLeftText;
	if(FlexGlobals.topLevelApplication.parameters.timeLeft!=null) myRecorder.timeLeft= FlexGlobals.topLevelApplication.parameters.timeLeft;
	if(FlexGlobals.topLevelApplication.parameters.mode!=null) myRecorder.mode= FlexGlobals.topLevelApplication.parameters.mode;
	if(FlexGlobals.topLevelApplication.parameters.backToRecorder!=null) myRecorder.backToRecorder= FlexGlobals.topLevelApplication.parameters.backToRecorder;
	if(FlexGlobals.topLevelApplication.parameters.backText!=null) myRecorder.backText= FlexGlobals.topLevelApplication.parameters.backText;
	
	//Application.application.width = myRecorder.width;
	//Application.application.height = myRecorder.height;

	recordingTimer.addEventListener( "timer" , decrementTimer );

	timeLeft = myRecorder.maxLength.toString();
  	nc=new NetConnection();		
	nc.client=this;		
	nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
	nc.connect(myRecorder.server);	

	
	
	if (myRecorder.mode=="player") {
		currentState="player";
	} else {
		currentState="";
	}
	
}

 private function formatPositionToolTip(value:Number):String{
	return value.toFixed(2) +" s";
 }

private function handleGaugeEvent( event:GaugeEvent ) : void{	
	videoPlayer.volume = event.value/100;
}

private function netStatusHandler(event:NetStatusEvent):void {
	switch (event.info.code) {
	case "NetConnection.Connect.Failed":
		Alert.show("ERROR:Could not connect to: "+myRecorder.server);
	break;	
    case "NetConnection.Connect.Success":
    	prepareStreams();
    break;
	default:
		nc.close();
		break;
    }
}
public function recordStart():void {
	nsOutGoing.publish(myRecorder.fileName, "record");
	myRecorder.hasRecorded = true;
}
public function recordFinished():void {
	nsOutGoing.close();
}
private  function decrementTimer( event:TimerEvent ):void {
	var minutes:int;
	var seconds:int;
	//myRecorder.timeLeft--;
	minutes = myRecorder.timeLeft / 60;
	seconds = myRecorder.timeLeft % 60;
	if (minutes<10) timeLeft="0"+ minutes+":" else timeLeft=minutes+":";
	if (seconds<10) timeLeft=timeLeft+"0"+ seconds else timeLeft=timeLeft+seconds;

	
	// format to display mm:ss format
	if (myRecorder.timeLeft==0) {
		//recordFinished();
	}
}

public function webcamParameters():void {
	Security.showSettings(SecurityPanel.DEFAULT);
}
private function drawMicLevel(evt:TimerEvent):void {
		var ac:int=mic.activityLevel;
		micLevel.setProgress(ac,100);
}

private  function prepareStreams():void {
	if (myRecorder.mode != "player") {
		nsOutGoing = new NetStream(nc); 
		camera=Camera.getCamera();
		if (camera==null) {
			Alert.show("Webcam not detected !");
		}
		if (camera!=null) {
			if (camera.muted) 	{
				Security.showSettings(SecurityPanel.DEFAULT);
			}
			camera.setMode(myRecorder.width,myRecorder.height,myRecorder.fps);
			myWebcam.attachCamera(camera);
			nsOutGoing.attachCamera(camera);
			myRecorder.cameraDetected=true;
			camera.addEventListener(StatusEvent.STATUS, cameraStatus); 
		}	
	
		mic=Microphone.getMicrophone(0);
		if (mic!=null) {
	        mic.rate=myRecorder.microRate;
	        var timer:Timer=new Timer(50);
			timer.addEventListener(TimerEvent.TIMER, drawMicLevel);
			timer.start();
			nsOutGoing.attachAudio(mic);
		}	
	} else {
		nsInGoing= new NetStream(nc);
		nsInGoing.client=this;
		nsInGoing.play(myRecorder.fileName);
	}			            
}   
private function cameraStatus(evt:StatusEvent):void {
	switch (evt.code) {
	case "Camera.Muted":
		myRecorder.cameraDetected=false;
		break;
	case "Camera.Unmuted":
    	myRecorder.cameraDetected=true;
	break;
    }
}   
