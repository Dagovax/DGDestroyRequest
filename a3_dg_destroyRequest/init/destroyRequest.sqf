if (!isServer) exitWith {};

if (isNil "DGDR_UseDynamicPositions") then
{
	diag_log format["%1 Waiting until configuration completes...", "[DG DestroyRequest]"];
	waitUntil{uiSleep 10; !(isNil "DGDR_UseDynamicPositions")}
};

diag_log format["%1 Initializing Destruction Request", DGDR_MessageName];

// Debug settings
if(DGDR_DebugMode) then 
{
	diag_log format['%1 Running in Debug mode!',DGDR_MessageName];
	DGDR_CleanUpTime = 10;
	DGDR_TMin = 10;
	DGDR_TMax	= 30;
	DGDR_LandStartPositions = [[10943.8,8572.91,0]];
	DGDR_LandEndPositions = 	[[12676,9683,0]];
	DGDR_AirStartPositions = [[10943.8,8572.91,0]];
	DGDR_AirEndPositions = [[12676,9683,0]];
	DGDR_MaxMissions = 20;
	DGDR_MinOnline = 0;
};
DGDR_SpawnKind = ["FLY", "CAN_COLLIDE"];

if (DGDR_MinOnline > 0) then
{
	diag_log format ["%1 Waiting for %2 players to be online.",DGDR_MessageName, DGDR_MinOnline];
	waitUntil { uiSleep 10; count( playableUnits ) > ( DGDR_MinOnline - 1 ) };
};
diag_log format ["%1 %2 players reached. Initializing main loop", DGDR_MessageName, DGDR_MinOnline];

_middle = worldSize/2;
_center = [_middle,_middle,0];
_maxDistance = _middle;
diag_log format["%1 Calculated _middle [%2], _center [%3] and _maxDistance [%4]", DGDR_MessageName, _middle, _center, _maxDistance];

// Sleep until first spawn
_initialWaitTime =  (DGDR_TMin) + random((DGDR_TMax) - (DGDR_TMin)); // + diag_tickTime
diag_log format["%1 Waiting %2 seconds before first spawn...", DGDR_MessageName, _initialWaitTime];
uiSleep _initialWaitTime; // Wait until the random counter started

DGDR_DestructionQueue = []; // Queue of active missions

_reInitialize = true; // Only initialize this when _reInitialize is true

while {true} do
{
	if(_reInitialize) then
	{
		_reInitialize = false;
		if(count DGDR_DestructionQueue >= DGDR_MaxMissions) exitWith{
			diag_log format ["%1 There are already [%2] missions active, which is the max (DGDR_MaxMissions=%3)",DGDR_MessageName, count DGDR_DestructionQueue, DGDR_MaxMissions];
		};	
		_isFlying = false;

		// Select random type (Land | Air)
		_spawnType = selectRandom DGDR_SpawnKind;

		_startPosition = [0,0,0];
		if (DGDR_UseDynamicPositions) then
		{
			if(_spawnType == "FLY") then
			{
				_startPosition = [_center,5000,_middle,0,1,20,0] call BIS_fnc_findSafePos; // Spawn heli in this radius
			} else
			{
				_randomPos = [_center,5000,_middle,0,0,20,0] call BIS_fnc_findSafePos;
				_allRoads = _randomPos nearRoads 2000; // Get all roads near the pos
				if(count _allRoads > 0) then
				{
					_startPosition = getPos (selectRandom _allRoads); // Spawn vehicle on a road
				} else
				{
					_startPosition = _randomPos;
				};
			};
		} else
		{
			_startPosition = switch (_spawnType) do 
			{
				case "FLY": {
					selectRandom DGDR_AirStartPositions; 
				};
				default { 
					[selectRandom DGDR_LandStartPositions,1,50,DGDR_MinDist,DGDR_Water,20,DGDR_ShoreMode] call BIS_fnc_findSafePos; 
				};
			};
		};

		_endPosition = [0,0,0];
		if (DGDR_UseDynamicPositions) then
		{
			_startX = _startPosition select 0;
			_startY = _startPosition select 1;
			_endPosX = 0;
			_endPosY = 0;
			
			if(_startX < _middle) then
			{
				// X coord of spawnpos is lower than middle
				_diff = _middle - _startX;
				_endPosX = _diff + _middle;
			};
			if(_startX > _middle) then
			{
				// X coord of spawnpos is higher than middle
				_diff = _startX - _middle;
				_endPosX = _middle - _diff;
			};
			if(_startX == _middle) then
			{
				_endPosX = selectRandom [0, worldSize];
			};
			
			
			if(_startY < _middle) then
			{
				// Y coord of spawnpos is lower than middle
				_diff = _middle - _startY;
				_endPosY = _diff + _middle;
			};
			if(_startY > _middle) then
			{
				// Y coord of spawnpos is higher than middle
				_diff = _startY - _middle;
				_endPosY = _middle - _diff;
			};
			if(_startY == _middle) then
			{
				_endPosY = selectRandom [0, worldSize];
			};
		
			_endPos = [_endPosX, _endPosY, 0];
			//diag_log format ["%1 DEBUG: _startDiffX = %2 | _startDiffY = %3 | _endPosX = %4 | _endPosY = %5  | _endPos = %6",DGDR_MessageName, _startDiffX, _startDiffY, _endPosX, _endPosY, _endPos];
			if(_spawnType == "FLY") then
			{
				_endPosition = [_endPos,1000,2000,0,1,20,0] call BIS_fnc_findSafePos;
			} else
			{
				_randomPos = [_endPos,1000, 2000,0,0,20,0] call BIS_fnc_findSafePos;
				_allRoads = _randomPos nearRoads 1000; // Get all roads near the pos
				if(count _allRoads > 0) then
				{
					_endPosition = getPos (selectRandom _allRoads); // Spawn vehicle on a road
				} else
				{
					_endPosition = _randomPos;
				};
			};
		} else
		{
			_endPosition = switch (_spawnType) do 
			{
				case "FLY": { 
					selectRandom DGDR_AirEndPositions 
				};
				default { 
					selectRandom DGDR_LandEndPositions 
				};
			};
		};
		
		if (_spawnType == "FLY") then 
		{
			_isFlying = true;
		};

		if((_startPosition isEqualTo [0,0,0]) || (_endPosition isEqualTo [0,0,0])) exitWith {
			diag_log format ["%1 ERROR: _startPosition [%2] or _endPosition [%3] equals [0,0,0]. Not spawning this mission now.",DGDR_MessageName, _startPosition, _endPosition];
		};

		[_startPosition, _endPosition, _spawnType, _isFlying] spawn
		{
			params ["_startPosition", "_endPosition", "_spawnType", "_isFlying"];
			_wayPoints		= [];
			_killedByPlayer = false;
			_wayPointReached = false; // Set to true when he reached the waypoint!
			
			// Add a final CYCLE
			_wp = [_endPosition,"MOVE"];
			_wayPoints pushBack _wp;
			
			// Create the vehicle and ensure he doest react to gunfire or being shot at.
			_group = createGroup DGDR_AISide;
			_group setCombatMode "BLUE";
			
			_desDriver = _group createUnit [DGDR_UnitType, _startPosition, [], 0, "NONE"];
			{_x disableAI "AUTOTARGET"; _x disableAI "TARGET"; _x disableAI "SUPPRESSION";} forEach units _group;
			_desDriver allowDamage true;
			_desDriver forceAddUniform DGDR_Uniform;
			_desDriver addVest DGDR_Vest;
			_desDriver addBackpack DGDR_Backpack;
			_desDriver AddWeapon "CUP_srifle_AS50";
			_desDriver addPrimaryWeaponItem "optic_AMS";
			_desDriver addHeadgear DGDR_Headgear;
			
			_vicPos = position _desDriver;
			_mk = createMarker [format ["%1_%2_%3", "_destructionRequest", _startPosition select 0, _startPosition select 1], _vicPos];
			DGDR_DestructionQueue pushBack _mk;
						
			// Spawn Vehicle
			_vehicleClass = switch (_spawnType) do 
			{
				case "FLY": { selectRandom DGDR_VehicleAir };
				default { selectRandom DGDR_VehicleLand };
			};
			_vehicleObject = createVehicle [_vehicleClass, _startPosition, [], 0, _spawnType];
			_vehicleObject flyInHeight DGDR_FlyingHeight;
			if (_isFlying) then 
			{
				_vehicleObject limitSpeed DGDR_AirMaxSpeed;
			} 
			else
			{
				_vehicleObject limitSpeed DGDR_LandMaxSpeed;
			};
			
			_vehicleName = getText (configFile >> "CfgVehicles" >> (typeOf _vehicleObject) >> "displayName");
			
			_desDriver setVariable ["_vehicleName", _vehicleName];
			_desDriver setVariable ["_vehicleObject", _vehicleObject];
			_desDriver setVariable ["_spawnType", _spawnType];
			_desDriver setVariable ["_mk", _mk];
			
			_desDriver addEventHandler ["Killed", {
				params ["_unit", "_killer", "_instigator", "_useEffects"];	
				diag_log format['%1 The vehicle driver got killed by %2',DGDR_MessageName, _killer];
				_killerName = "A player";
				_vehicleObject = _unit getVariable "_vehicleObject";
				_spawnType = _unit getVariable "_spawnType";
				_vehicleObject setDamage 1;
				_reachedEnd = _unit getVariable "_reachedEnd";
				if(isNil "_reachedEnd") then
				{ 
					_reachedEnd = false;
				};
				_vehicleName = _unit getVariable "_vehicleName";
				_mk = _unit getVariable "_mk";
				if (isNil "_mk" || isNil "_vehicleName") exitWith{};
				_killedByPlayer = false;
				DGDR_DestructionQueue deleteAt (DGDR_DestructionQueue find _mk); // Delete this stuff from the queue
				
				deleteMarker _mk;
				if (!isNil "_killer" && !isNull _killer) then
				{
					_killerName = name _killer;
					_headlessClients = entities "HeadlessClient_F";
					_playerList = allPlayers - _headlessClients;

					if (DGDR_DebugMode) then
					{
						diag_log format['%1 Online players: %2',DGDR_MessageName, _playerList];
					};
					{ 
						if (name _x == _killerName) exitWith
						{
							diag_log format['%1 The vehicle got destroyed by %2!',DGDR_MessageName, _killerName];
							_killedByPlayer = true;
						};
					} forEach _playerList;
				};
				
				if (_killedByPlayer) then
				{
					_msgWin = format["%1 succesfully destroyed the %2! Don't forget the loot!", _killerName, _vehicleName];
					_currentPos = getPos _unit;
					// Message that mission is over and loot!
					// Toaster
					[
						"toastRequest",
						[
							"SuccessEmpty",
							[
								format
								[
									"<t color='#0080ff' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
									DGDR_ExileToasts_Title_Size,
									DGDR_ExileToasts_Title_Font,
									DGDR_MarkerName,
									DGDR_ExileToasts_Message_Color,
									DGDR_ExileToasts_Message_Size,
									DGDR_ExileToasts_Message_Font,
									_msgWin
								]
							]
						]
					] call ExileServer_system_network_send_broadcast;
				
					// Spawn loot Box duhh
					if (DGDR_EnableLoot) then
					{
						switch (_spawnType) do 
						{
							case "FLY": { 
								_enablePara = false;
								_crateSpawnHeight = -5;
								if((_currentPos select 2) > 10) then 
								{
									_enablePara = true;
								} else
								{
									_crateSpawnHeight = 10;
								};
								_crateSpawnPos = [(_currentPos select 0), (_currentPos select 1), (_currentPos select 2) + _crateSpawnHeight];
								_crate = createVehicle [DGDR_LootBoxType, _crateSpawnPos, [], 0, "CAN_COLLIDE"];
								_crate allowDamage false;
								_crate setVariable ["ExileIsPersistent", false];
								
								//Add content to crate
								{
									if (_forEachIndex == 0) then { // DGDR_LootWeapons
										for "_i" from 1 to _x do
										{
											_weapon = DGDR_LootWeapons call BIS_fnc_selectRandom;
											_ammo = _weapon call DGDestroyRequest_fnc_selectMagazine;
											if (_weapon isEqualType "") then
											{
												_weapon = [_weapon,1];
											};
											_crate addWeaponCargoGlobal _weapon;
											if !(_ammo in ["Exile_Magazine_Swing","Exile_Magazine_Boing","Exile_Magazine_Swoosh"]) then
											{
												_crate addItemCargoGlobal [_ammo, 2];
											};
										};
									};
									if (_forEachIndex == 1) then { // DGDR_LootVests
										for "_i" from 1 to _x do
										{
											_vest = DGDR_LootVests call BIS_fnc_selectRandom;
											if (_vest isEqualType "") then
											{
												_vest = [_vest,1];
											};
											_crate addItemCargoGlobal _vest;
										};
									};
									if (_forEachIndex == 2) then { // DGDR_LootBackpacks
										for "_i" from 1 to _x do
										{
											_bp = DGDR_LootBackpacks call BIS_fnc_selectRandom;
											if (_bp isEqualType "") then
											{
												_bp = [_bp,1];
											};
											_crate addItemCargoGlobal _bp;
										};
									};
									if (_forEachIndex == 3) then { // DGDR_LootMaterial
										for "_i" from 1 to _x do
										{
											_material = DGDR_LootMaterial call BIS_fnc_selectRandom;
											if (_material isEqualType "") then
											{
												_material = [_material,1];
											};
											_crate addItemCargoGlobal _material;
										};
									};
									if (_forEachIndex == 4) then { // DGDR_BuildingMaterials
										for "_i" from 1 to _x do
										{
											_bmaterial = DGDR_BuildingMaterials call BIS_fnc_selectRandom;
											if (_bmaterial isEqualType "") then
											{
												_bmaterial = [_bmaterial,1];
											};
											_crate addItemCargoGlobal _bmaterial;
										};
									};
									if (_forEachIndex == 5) then { // DGDR_LootMedicalItems
										for "_i" from 1 to _x do
										{
											_medical = DGDR_LootMedicalItems call BIS_fnc_selectRandom;
											if (_medical isEqualType "") then
											{
												_medical = [_medical,1];
											};
											_crate addItemCargoGlobal _medical;
										};
									};
									if (_forEachIndex == 6) then { // DGDR_LootWeaponAttachments
										for "_i" from 1 to _x do
										{
											_attachments = DGDR_LootWeaponAttachments call BIS_fnc_selectRandom;
											if (_attachments isEqualType "") then
											{
												_attachments = [_attachments,1];
											};
											_crate addItemCargoGlobal _attachments;
										};
									};
									if (_forEachIndex == 7) then { // DGDR_LootRareStuff
										for "_i" from 1 to _x do
										{
											_rare = DGDR_LootRareStuff call BIS_fnc_selectRandom;
											if (_rare isEqualType "") then
											{
												_rare = [_rare,1];
											};
											_crate addItemCargoGlobal _rare;
										};
									};
								} forEach DGDR_LootCounts;
								_money = ceil((DGDR_LootPoptabsMin) + random((DGDR_LootPoptabsMax) - (DGDR_LootPoptabsMin)));
								_crate setVariable ["ExileMoney",_money ,true];
								
								diag_log format ["%1 Spawning Airdrop with crate %2 at %3", DGDR_MessageName, DGDR_LootBoxType, position _crate];
								if (_enablePara) then
								{
									[_crate, _crateSpawnPos] spawn
									{
										params ["_crate", "_crateSpawnPos"];	
										WaitUntil {(((position _crate) select 2) < ((_crateSpawnPos select 2)-20))};
										_cratePosDrop = position _crate;
										_para = createVehicle ["B_Parachute_02_F", _cratePosDrop, [], 0, ""];
										_crate attachTo [_para,[0,0,-1.5]];
										
										//Wait until land
										WaitUntil {((((position _crate) select 2) < 7) || (isNil "_para"))};
										detach _crate;
									};
								};
							};
							default {
								_crateSpawnPos = [(_currentPos select 0), (_currentPos select 1) - 10, (_currentPos select 2) + 10];
								_crate = createVehicle [DGDR_LootBoxType, _crateSpawnPos, [], 0, "CAN_COLLIDE"];
								_crate allowDamage false;
								_crate setVariable ["ExileIsPersistent", false];
								
								//Add content to crate
								{
									if (_forEachIndex == 0) then { // DGDR_LootWeapons
										for "_i" from 1 to _x do
										{
											_weapon = DGDR_LootWeapons call BIS_fnc_selectRandom;
											_ammo = _weapon call DGDestroyRequest_fnc_selectMagazine;
											if (_weapon isEqualType "") then
											{
												_weapon = [_weapon,1];
											};
											_crate addWeaponCargoGlobal _weapon;
											if !(_ammo in ["Exile_Magazine_Swing","Exile_Magazine_Boing","Exile_Magazine_Swoosh"]) then
											{
												_crate addItemCargoGlobal [_ammo, 2];
											};
										};
									};
									if (_forEachIndex == 1) then { // DGDR_LootVests
										for "_i" from 1 to _x do
										{
											_vest = DGDR_LootVests call BIS_fnc_selectRandom;
											if (_vest isEqualType "") then
											{
												_vest = [_vest,1];
											};
											_crate addItemCargoGlobal _vest;
										};
									};
									if (_forEachIndex == 2) then { // DGDR_LootBackpacks
										for "_i" from 1 to _x do
										{
											_bp = DGDR_LootBackpacks call BIS_fnc_selectRandom;
											if (_bp isEqualType "") then
											{
												_bp = [_bp,1];
											};
											_crate addItemCargoGlobal _bp;
										};
									};
									if (_forEachIndex == 3) then { // DGDR_LootMaterial
										for "_i" from 1 to _x do
										{
											_material = DGDR_LootMaterial call BIS_fnc_selectRandom;
											if (_material isEqualType "") then
											{
												_material = [_material,1];
											};
											_crate addItemCargoGlobal _material;
										};
									};
									if (_forEachIndex == 4) then { // DGDR_BuildingMaterials
										for "_i" from 1 to _x do
										{
											_bmaterial = DGDR_BuildingMaterials call BIS_fnc_selectRandom;
											if (_bmaterial isEqualType "") then
											{
												_bmaterial = [_bmaterial,1];
											};
											_crate addItemCargoGlobal _bmaterial;
										};
									};
									if (_forEachIndex == 5) then { // DGDR_LootMedicalItems
										for "_i" from 1 to _x do
										{
											_medical = DGDR_LootMedicalItems call BIS_fnc_selectRandom;
											if (_medical isEqualType "") then
											{
												_medical = [_medical,1];
											};
											_crate addItemCargoGlobal _medical;
										};
									};
									if (_forEachIndex == 6) then { // DGDR_LootWeaponAttachments
										for "_i" from 1 to _x do
										{
											_attachments = DGDR_LootWeaponAttachments call BIS_fnc_selectRandom;
											if (_attachments isEqualType "") then
											{
												_attachments = [_attachments,1];
											};
											_crate addItemCargoGlobal _attachments;
										};
									};
									if (_forEachIndex == 7) then { // DGDR_LootRareStuff
										for "_i" from 1 to _x do
										{
											_rareStuff = DGDR_LootRareStuff call BIS_fnc_selectRandom;
											if (_rareStuff isEqualType "") then
											{
												_rareStuff = [_rareStuff,1];
											};
											_crate addItemCargoGlobal _rareStuff;
										};
									};
								} forEach DGDR_LootCounts;
								_money = ceil((DGDR_LootPoptabsMin) + random((DGDR_LootPoptabsMax) - (DGDR_LootPoptabsMin)));
								_crate setVariable ["ExileMoney",_money ,true];
								diag_log format ["%1 Spawning Landdrop with crate %2 at %3", DGDR_MessageName, DGDR_LootBoxType, position _crate];
							};
						};
					};
				} else
				{
					diag_log format['%1 The driver of vehicle %2 never reached his end...The fool exploded itself!',DGDR_MessageName, _vehicleName];
					// Toaster
					
					if(!_reachedEnd) then // If he reached the end waypoint, there is no message for this
					{
						_msgLoseExploded = format["The %1 exploded out of nowhere, and all the loot is gone!", _vehicleName];
						[
							"toastRequest",
							[
								"ErrorEmpty",
								[
									format
									[
										"<t color='#FF0000' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
										DGDR_ExileToasts_Title_Size,
										DGDR_ExileToasts_Title_Font,
										DGDR_MarkerName,
										DGDR_ExileToasts_Message_Color,
										DGDR_ExileToasts_Message_Size,
										DGDR_ExileToasts_Message_Font,
										_msgLoseExploded
									]
								]
							]
						] call ExileServer_system_network_send_broadcast;
					};
				};

				[_unit, _vehicleObject, _vehicleName] spawn
				{
					params ["_unit", "_vehicleObject", "_vehicleName"];	
					diag_log format["%1 Waiting %2 seconds before cleaning up this wreckage.", DGDR_MessageName, DGDR_CleanUpTime];
					uiSleep DGDR_CleanUpTime;
				
					// Remove wreck
					diag_log format["%1 Cleaning the finished driver and vehicle %2", DGDR_MessageName, _vehicleName];
					deleteVehicle _unit;
					deleteVehicle _vehicleObject;
				};
			}];

			clearBackpackCargoGlobal _vehicleObject;
			clearItemCargoGlobal _vehicleObject;
			clearMagazineCargoGlobal _vehicleObject;
			clearWeaponCargoGlobal _vehicleObject;
			_vehicleObject setVariable ["ExileIsPersistent", false];
			_vehicleObject setFuel 1; 
			diag_log format['%1 Vehicle %2 spawned @ %3',DGDR_MessageName, _vehicleClass, _startPosition];
			diag_log format['%1 Vehicle %2 moving to %3',DGDR_MessageName, _vehicleName, _endPosition];
			
			// Send message to client
			// Define Mission Start message
			_msgStart = "";
			if (DGDR_EnableMusic && DGDR_ShowMarker) then
			{
				_msgStart = format["Destroy the %1 and earn yourself loot! Follow the music and the marker on the map!", _vehicleName];
			};
			if (DGDR_EnableMusic && !DGDR_ShowMarker) then	
			{
				_msgStart = format["Destroy the %1 and earn yourself loot! Follow the music surrounding the vehicle!", _vehicleName];
			};
			if (!DGDR_EnableMusic && DGDR_ShowMarker) then
			{
				_msgStart = format["Destroy the %1 and earn yourself loot! Check the marker on the map!", _vehicleName];
			};
			
			// Define Mission Lose message
			_msgLose = format["The %1 exploded after reaching his destination... Someone else left off with all the loot!", _vehicleName];

			// Broadcast system chat
			format["%1: %2",toUpper DGDR_MarkerName,_msgStart] remoteExecCall ["systemChat",-2];
			// Toaster
			[
				"toastRequest",
				[
					"InfoEmpty",
					[
						format
						[
							"<t color='#31a3e0' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
							DGDR_ExileToasts_Title_Size,
							DGDR_ExileToasts_Title_Font,
							DGDR_MarkerName,
							DGDR_ExileToasts_Message_Color,
							DGDR_ExileToasts_Message_Size,
							DGDR_ExileToasts_Message_Font,
							_msgStart
						]
					]
				]
			] call ExileServer_system_network_send_broadcast;	
			
			_desDriver assignasdriver _vehicleObject;
			[_desDriver] orderGetin true;	 
			{
				_wpName = _x select 0;
				_wpType = _x select 1;
				_wp = _group addWaypoint [_x select 0, 1];
				_wp setWaypointType _wpType;
				_wp setWaypointBehaviour DGDR_AIBehaviour;
				_wp setWaypointspeed DGDR_AISpeed; 
				_wp setWaypointCompletionRadius DGDR_FailRadius;
				//_wp setWaypointStatements [""true"", ""_vehicleObject setDamage 1;""];
				//_wp setWaypointStatements ["true", "_vehicleObject setDamage 1;"];
				diag_log format['%1 Waypoint %2 Type: %3', DGDR_MessageName, _wpName,_wpType];
			} forEach _wayPoints;
			
			_group setVariable ["_msgLose", _msgLose];
			_group setVariable ["_vehicleName", _vehicleName];
			_group setVariable ["_vehicleObject", _vehicleObject];
			
			// Event handler for reaching the waypoint
			_group addEventHandler ["WaypointComplete", {
				_this spawn
				{
					params ["_group", "_waypointIndex"];
					if(_waypointIndex < 1) exitWith {
						_waypoint = (waypoints _group) select 0;
						_group setCurrentWaypoint [_group, 1]; // Make sure they move to the end waypoint
						_waypoint setWaypointType "MOVE"; // Make sure they move
					};
					_vehicleName = _group getVariable "_vehicleName";
					_vehicleObject = _group getVariable "_vehicleObject";
					_msgLose = _group getVariable "_msgLose";
					_leader = leader _group;
					_leader setVariable ["_reachedEnd", true];
					diag_log format['%1 The %2 reached its target! Mission failed!', DGDR_MessageName, _vehicleName];
					// Toaster
					[
						"toastRequest",
						[
							"ErrorEmpty",
							[
								format
								[
									"<t color='#FF0000' size='%1' font='%2'>%3</t><br/><t color='%4' size='%5' font='%6'>%7</t>",
									DGDR_ExileToasts_Title_Size,
									DGDR_ExileToasts_Title_Font,
									DGDR_MarkerName,
									DGDR_ExileToasts_Message_Color,
									DGDR_ExileToasts_Message_Size,
									DGDR_ExileToasts_Message_Font,
									_msgLose
								]
							]
						]
					] call ExileServer_system_network_send_broadcast;
					_vehicleObject setDamage 1;
				};
			}];

			if (DGDR_ShowMarker) then
			{
				_mk setMarkerType DGDR_MarkerType;
				_mk setMarkerText _vehicleName; //DGDR_MarkerName;
				_mk setMarkerColor DGDR_MarkerColor;
				_mk setMarkerSize [0.6, 0.6];
			};
			
			_vehicleObject setVehicleLock "UNLOCKED";
			
			if (DGDR_CanMove) then 
			{
				_desDriver assignasdriver _vehicleObject;
				[_desDriver] orderGetin true;
				_desDriver moveInDriver _vehicleObject;
				_desDriver action ["LightOn", _desDriver];
				_desDriver enableAI "MOVE";
			} else
			{
				_desDriver assignasdriver _vehicleObject;
				[_desDriver] orderGetin true;
				_desDriver moveInDriver _vehicleObject;
				_desDriver disableAI "MOVE";
				diag_log format['%1 DGDR_CanMove is set to false, so AI will not move...', DGDR_MessageName];
			};
			
			// Select random track for this round
			_musicTrack = selectRandom DGDR_MusicTracks;
			_musicName = _musicTrack select 0;
			_musicLength = _musicTrack select 1;
			_musicPitch = _musicTrack select 2;
			if (DGDR_EnableMusic) then 
			{
				diag_log format['%1 Looping sound %2 on vehicle [%6] with range %3 and pitch %4 for this amount of seconds: %5', DGDR_MessageName, _musicName, DGDR_MusicRange, _musicPitch, _musicLength, _vehicleClass];
				[_vehicleObject,[_musicName, DGDR_MusicRange, _musicPitch]] remoteExec ["say3d",0,true];
				
			};
			
			// Keep the AI moving to the marker
			_idleTimer = 0;
			_idleTimeWarning = 20; // How much seconds to log the vehicle is idle?
			_idleTimeLog = 1; // Factor of above to count how much time it is logged already...
			_idlePosition = _startPosition;
			_musicTimer = 0;
			while {true} do
			{
				_currentPos = getPos _vehicleObject;
				if (!alive _desDriver || !alive _vehicleObject) exitWith{};
				
				if ((_currentPos distance2D _idlePosition) <= DGDR_IdleRange) then 
				{
					_idleTimer = _idleTimer + DGDR_UpdateTime;
					if (_idleTimer > (_idleTimeWarning * _idleTimeLog)) then
					{
						_idleTimeLog = _idleTimeLog + 1;
						diag_log format['%1 The %2 is stuck! Idle now for %3 seconds (max=%4)! Current pos= %5', DGDR_MessageName, _vehicleName, _idleTimer, DGDR_AIIdleTime, _currentPos];
					};
				} else
				{
					_idlePosition = _currentPos;
					_idleTimer = 0; // Reset the idle timer.
					if(_idleTimeLog > 1) then // Log that the behicle is not idle anymore
					{
						diag_log format['%1 The %2 is not idle anymore. Current pos= %3', DGDR_MessageName, _vehicleName, _currentPos];
					};
					_idleTimeLog = 1; // Reset idle time logger
				};
			
				if (DGDR_CanMove) then 
				{
					_desDriver assignasdriver _vehicleObject;
					[_desDriver] orderGetin true;
					_desDriver moveInDriver _vehicleObject;
					_desDriver action ["LightOn", _desDriver];	
					_desDriver enableAI "MOVE";
				} else
				{
					_desDriver assignasdriver _vehicleObject;
					[_desDriver] orderGetin true;
					_desDriver moveInDriver _vehicleObject;
					_desDriver disableAI "MOVE";
					//diag_log format['%1 DGDR_CanMove is set to false, so AI will not move (looped message).', DGDR_MessageName];
				};

				if (DGDR_ShowMarker) then
				{
					_pos = position _vehicleObject;
					_mk setMarkerPos _pos;
				};
				
				_vehicleObject setFuel 1;
					
				uiSleep DGDR_UpdateTime;
				_musicTimer = _musicTimer + DGDR_UpdateTime;
				
				// Restart music track and timer
				if (_musicTimer >= _musicLength) then 
				{
					if(DGDR_EnableMusic) then 
					{
						diag_log format['%1 Playing sound %2 on vehicle [%6] with range %3 and pitch %4 and it will repeat after %5 seconds.', DGDR_MessageName, _musicName, DGDR_MusicRange, _musicPitch, _musicLength, _vehicleClass];
						
						[_vehicleObject,[_musicName, DGDR_MusicRange, _musicPitch]] remoteExec ["say3d",0,true];
					};
					_musicTimer = 0;
				};
				
				if (_idleTimer >= DGDR_AIIdleTime) exitWith
				{
					diag_log format['%1 The %2 is stuck somehow, it is idle now for over %3 seconds, while the maximum idle time = %4 seconds. Finishing it off..', DGDR_MessageName, _vehicleName, _idleTimer, DGDR_AIIdleTime];
					_desDriver setDamage 1;
					_vehicleObject setDamage 1;
				};
			};
		};
	};
	_reInitialize = true;
	// Sleep until next spawn
	_nextWaitTime =  (DGDR_TMin) + random((DGDR_TMax) - (DGDR_TMin)); // + diag_tickTime
	diag_log format["%1 Waiting %2 seconds before next spawn...", DGDR_MessageName, _nextWaitTime];
	uiSleep _nextWaitTime; // Wait until the random counter started
	diag_log format ["%1 List of active destruction missions [%2]: %3", DGDR_MessageName, count DGDR_DestructionQueue, DGDR_DestructionQueue];
};

