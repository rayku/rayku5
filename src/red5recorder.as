// ActionScript file
import flash.external.ExternalInterface;
import flash.media.Camera;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.Application;
import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.CloseEvent;
import mx.events.VideoEvent;

import classes.Recorder;

import components.gauge.events.GaugeEvent;

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
[Bindable] public var timeLeft:String="";
private var isReconnect:Boolean=false;



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
	if(FlexGlobals.topLevelApplication.parameters.live!=null) myRecorder.live = FlexGlobals.topLevelApplication.parameters.live;
	
	timeLeft = myRecorder.maxLength.toString();
  	nc=new NetConnection();		
	nc.client=this;		
	nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
	nc.connect(myRecorder.server);	
	
	ExternalInterface.addCallback("play", playRecording);
	ExternalInterface.addCallback("stop", stopRecording);
	ExternalInterface.addCallback("pause", pauseToggle);
	ExternalInterface.addCallback("startRecording", recordStart);
	ExternalInterface.addCallback("stopRecording", recordFinished);
	ExternalInterface.addCallback("mute", mute);
	ExternalInterface.addCallback("unMute", unMute);
	
	if (myRecorder.mode=="player") {
		currentState="player";
	} else {
		currentState="";
	}
	
	if (myRecorder.mode!="player") {
		var alert:Alert = mx.controls.Alert.show('Click "OK" to continue.', 'Webcam Settings', mx.controls.Alert.OK, null, function(e:CloseEvent):void {
			flash.external.ExternalInterface.call("namespace.rayku.chatbox.views.webcam.prepared");
			recordStart();
		});
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
    case "NetConnection.Connect.Success":
    	prepareStreams();
    break;
	default:
		setTimeout(reconnect, 2000);
	break;
    }
}

private function reconnect():void {
	isReconnect = true;
	if (myRecorder.mode == 'player'){
		nsInGoing.close();
	} else {
		nsOutGoing.close();
	}
	nc.connect(myRecorder.server);
}

public function recordStart():void {
	nsOutGoing.publish(myRecorder.fileName, "append");
	myRecorder.hasRecorded = true;
}
public function recordFinished():void {
	nsOutGoing.close();
}

public function webcamParameters():void {
	Security.showSettings(SecurityPanel.PRIVACY);
}

public function playRecording():void {
	if (myRecorder.mode == "player") {
		nsInGoing.play(myRecorder.fileName);
	}
}

public function stopRecording():void {
	if (myRecorder.mode == "player") {
		nsInGoing.close();
	}
}

public function pauseToggle():void {
	if (myRecorder.mode == "player") {
		nsInGoing.togglePause();
	}
}

public function mute():void {
	if (myRecorder.mode == "player"){
		nsInGoing.receiveAudio(false);
	}
}

public function unMute():void {
	if (myRecorder.mode == "player"){
		nsInGoing.receiveAudio(true);
	}
}

private function drawMicLevel(evt:TimerEvent):void {
		var ac:int=mic.activityLevel;
		micLevel.setProgress(ac,100);
}

private  function prepareStreams():void {
	if (myRecorder.mode != "player") {
		if (!isReconnect){
			nsOutGoing = new NetStream(nc); 
		} else {
			nsOutGoing = new NetStream(nc);
		}
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
			mic.setSilenceLevel(0, -1);
			nsOutGoing.attachAudio(mic);
		}	
		if (isReconnect){
			recordStart();
		}
	} else {
		if (!isReconnect){
			nsInGoing= new NetStream(nc);
			videoPlayer.mx_internal::videoPlayer.attachNetStream(nsInGoing);
			videoPlayer.mx_internal::videoPlayer.visible = true;
			flash.external.ExternalInterface.call("namespace.rayku.chatbox.views.webcam.loaded");
		} else {
			nsInGoing= new NetStream(nc);
			videoPlayer.mx_internal::videoPlayer.attachNetStream(nsInGoing);
			videoPlayer.mx_internal::videoPlayer.visible = true;
			nsInGoing.play(myRecorder.fileName);
		}
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
