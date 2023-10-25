fa_point_fnc_point = { 
	// prevent player from spamming
	player setVariable ["fa_point_var_CAN_POINT",false];
	// animate
	player playActionNow "gestureGo";

	// Find where pointer object should be.
	private _max_distance = 100;
	private _eyeDir = getCameraViewDirection player; 
	private _eyePos = (eyePos player) vectorAdd (_eyeDir vectorMultiply 5); // draw from a few meters in front of player to let them point through windows.
	private _distance = _eyeDir vectorMultiply _max_distance; 
	private _finalPos = ((_eyePos) vectorAdd _distance);
	private _intersects = lineIntersectsSurfaces [_eyePos,_finalPos,objNull,objNull,true,1,"GEOM","NONE"]; // check if an object is less than 50m away, put the pointer object there
	if (_eyePos distance (_intersects select 0 select 0) < _max_distance) then {
		_finalPos = (_intersects select 0 select 0);
	};
	private _final_distance = _eyePos distance _finalPos;
	private _finalDir = getCameraViewDirection player;

	// Ask multiplayers if they are close enough to see the point	
	private _near_players = (player nearEntities ["Man", 3]) select {isPlayer _x};
	// use vehicle crew otherwise.
	if (vehicle player != player) then {
		_near_players = crew vehicle player;
	};
	[_finalPos,_finalDir,_final_distance] remoteExecCall ["fa_point_fnc_nearby",_near_players];

	// Allow player to point again.
	[] spawn {
		sleep 2; 
		player setVariable ["fa_point_var_CAN_POINT",true];
	};
};

fa_point_fnc_nearby = { 

	params ["_finalPos","_finalDir","_final_distance"];

	// create the object for the close people.
	private _floating_marker = createSimpleObject ["Sign_Circle_F", [0,0,0], true];

	// make it pretty
	// _floating_marker setObjectTexture [0,"#(argb,8,8,3)color(0.35,0.35,0.35,0.8,ca)"]; // grey
	_floating_marker setObjectTexture [0,"#(argb,8,8,3)color(0.05,0.05,0.05,0.8,ca)"]; // black
	// _floating_marker setObjectTexture [0,"#(argb,8,8,3)color(0.95,0.95,0.95,0.8,ca)"]; // white
	_floating_marker setObjectMaterial [0,"a3\structures_f_bootcamp\vr\coverobjects\data\vr_coverobject_basic.rvmat"];

	// Put it in the right spot
	private _scale = linearConversion [0, 105, _final_distance, 0.1, 0.6, false];
	_floating_marker setPosAsl _finalPos; 
	_floating_marker setVectorDirAndUp [_finalDir,[0,0,1]];
	_floating_marker setObjectScale _scale;

	// Delete the object after some time
	_floating_marker spawn {
		sleep 2; 
		deleteVehicle _this; 
	};
};

addUserActionEventHandler ["TacticalPing", "Activate", {
	params ["_activated"];
	if (player getVariable ["fa_point_var_CAN_POINT",true]) then {
		call c_fnc_fa_point;
	};
}];

if (isServer) then {
	publicVariable "c_fnc_fa_point_init";
	remoteExec ["c_fnc_fa_point_init",0,true];
} else {
	call c_fnc_fa_point_init;
};
