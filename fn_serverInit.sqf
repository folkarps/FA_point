// Folk ARPS server-side pointing mod by Costno & NikkoJT
// https://folkarps.com - https://github.com/folkarps/fa_point
// This mod runs on the server and gives players an improved pointing feature, tied to the Tactical Ping keybind. Tactical Ping should be disabled in the server difficulty settings. Clients do not need this mod and should not load it.

if !isServer exitWith{};

fa_point_fnc_point = compileFinal { 
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

	// Ask multiplayers if they are close enough to see the point	
	private _near_players = (player nearEntities ["CAManBase", 3]) select {isPlayer _x};
	// use vehicle crew otherwise.
	if (vehicle player != player) then {
		_near_players = crew vehicle player;
	};
	[_finalPos,_eyeDir,_final_distance] remoteExecCall ["fa_point_fnc_nearby",_near_players];

	// Allow player to point again.
	[] spawn {
		sleep 2; 
		player setVariable ["fa_point_var_CAN_POINT",true];
	};
};

publicVariable "fa_point_fnc_point";

fa_point_fnc_nearby = compileFinal { 

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
	_floating_marker setPosASL _finalPos; 
	_floating_marker setVectorDirAndUp [_finalDir,[0,0,1]];
	_floating_marker setObjectScale _scale;

	// Delete the object after some time
	_floating_marker spawn {
		sleep 2; 
		deleteVehicle _this; 
	};
};

publicVariable "fa_point_fnc_nearby";

[["TacticalPing", "Activate", {
	if (missionNamespace getVariable ["fa_point_var_override",false]) exitWith{};
	if !(alive player) exitWith{};
	if !(lifeState player in ["HEALTHY","INJURED"]) exitWith{};
	if !(player getVariable ["f_var_fam_conscious",true]) exitWith{};
	if (player getVariable ["fa_point_var_CAN_POINT",true]) then {
		call fa_point_fnc_point;
	};
}]] remoteExec ["addUserActionEventHandler",0,true];