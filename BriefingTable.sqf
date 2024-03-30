private _text_Generate_Ace_DisplayName = "Generate Satellite 3D Terrain";
private _text_Generate_Hint_NotFound = "Couldn't find satellite!";
private _text_Clear_Ace_DisplayName = "Clear 3D Terrain";

private _text_Setting_Resolution_Ace_DisplayName = "Resolution Scale";
private _text_Setting_Resolution_Ace_DisplayName_Sub = "Set Scale to %1";
private _text_Setting_Resolution_Hint_Current = "Current set terrain resolution: %1";
private _text_Setting_Resolution_Hint_Updated = "Resolution was set to: %1";

private _text_Setting_Height_Ace_DisplayName = "Generation Height";
private _text_Setting_Height_Ace_DisplayName_Sub_Up = "Move up";
private _text_Setting_Height_Ace_DisplayName_Sub_Down = "Move down";
private _text_Setting_Height_Hint_Current = "Current set generation height: %1";
private _text_Setting_Height_Hint_Updated = "Generation height has been set to: %1 (was %2)";

private _text_Setting_TerrainType_Ace_DisplayName = "Terrain Type";
private _text_Setting_TerrainType_Ace_DisplayName_Sub_Flat = "Flat";
private _text_Setting_TerrainType_Ace_DisplayName_Sub_3D = "Three Dimensional";
private _text_Setting_TerrainType_Hint_Current = "Current set terrain type: %1";
private _text_Setting_TerrainType_Hint_Updated = "Terrain type has been set to: %1 (was %2)";

private _text_Setting_MarkerSize_Ace_DisplayName = "Terrain Zoom";
private _text_Setting_MarkerSize_Ace_DisplayName_Sub = "Set Zoom to %1";
private _text_Setting_MarkerSize_Hint_Current = "Current set terrain zoom: %1";
private _text_Setting_MarkerSize_Hint_Updated = "Terrain zoom has been set to: %1";



private _use_Custom_MapMarker = "";



[this] call MRH_fnc_isSatMonitor;
private _objectNetID = "_" + (netId this);
private _getNearestTable = nearestObject [this, "Land_CampingTable_small_white_F"];
 
missionNamespace setVariable ["isSatTableOn" + _objectNetID, false, true];
missionNamespace setVariable ["isGenerating" + _objectNetID, false, true];
missionNamespace setVariable ["zPosBlocks" + _objectNetID, 0, true];
missionNamespace setVariable ["terrainResolution" + _objectNetID, 25, true];
missionNamespace setVariable ["type" + _objectNetID, "3D", true];
missionNamespace setVariable ["markerSize" + _objectNetID, [250,250], true];



private _generateTerrain = ["BriefingTableSatelliteON", _text_Generate_Ace_DisplayName, "MRHSatellite\Paa\satellite.paa",
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_getNearestTable", "_text_Generate_Hint_NotFound", "_use_Custom_MapMarker"];

    private _tableReselution = missionNamespace getVariable ["terrainResolution" + _objectNetID, 25];
    private _terrainHeight = missionNamespace getVariable ["zPosBlocks" + _objectNetID, 25];
    private _markerSize = missionNamespace getVariable ["markerSize" + _objectNetID, [250,250]];
    private _terrainType = true;
    private _blockTime = 30;
    private _camera = uinameSpace getVariable "MRH_SATCAM";
    private _bearing = asin (vectorUp _camera select 0);
    private _markerToTrack = "SatPosMarker";

    if (_use_Custom_MapMarker != "") then { _markerToTrack = _use_Custom_MapMarker; };
    if (getMarkerPos [_markerToTrack, true] isEqualTo [0,0,0]) exitWith { hint _text_Generate_Hint_NotFound; };
    if (getMarkerPos ["HiddenSatPosMarker", true] isEqualTo [0,0,0]) then {
        createMarker ["HiddenSatPosMarker", (getMarkerPos [_use_Custom_MapMarker, true])];
    } else {
        "HiddenSatPosMarker" setMarkerPos getMarkerPos _markerToTrack;
    };

    "HiddenSatPosMarker" setMarkerSize _markerSize;

    if (_use_Custom_MapMarker == "") then {
        if (_bearing < 0) then {_bearing = 360 + _bearing};
        _bearing = [_bearing, 1] call BIS_fnc_cutDecimals;
        "HiddenSatPosMarker" setMarkerDir _bearing;
    };

    switch (_tableReselution) do {
        case 25: { _blockTime = 10; };
        case 50: { _blockTime = 30; };
        case 75: { _blockTime = 60; };
        case 100: { _blockTime = 120; };
    };

    if (missionNamespace getVariable ["type" + _objectNetID, "3D"] == "Flat") then { _terrainType = false; };

    missionNamespace setVariable ["isGenerating" + _objectNetID, true, true];
    missionNamespace setVariable ["isSatTableOn" + _objectNetID, true, true];

    [_getNearestTable, "HiddenSatPosMarker", _tableReselution, 2.1, _terrainType, true, _terrainHeight] remoteExec ["sebs_briefing_table_fnc_createTable", 0, _getNearestTable];

    [{
        params ["_objectNetID"];
        missionNamespace setVariable ["isGenerating" + _objectNetID, false, true];
    }, [_objectNetID], _blockTime] call CBA_fnc_waitAndExecute;

},
{ 
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_getNearestTable"];

    !(missionNamespace getVariable ["isSatTableOn" + _objectNetID, false]) && !(missionNamespace getVariable ["isGenerating" + _objectNetID, false])
}, {}, [_objectNetID, _getNearestTable, _text_Generate_Hint_NotFound, _use_Custom_MapMarker], [0,-1.35,0.37], 1] call ace_interact_menu_fnc_createAction;


  
private _clearTerrain = ["BriefingTableSatelliteOff", _text_Clear_Ace_DisplayName, "MRHSatellite\Paa\iconconnect.paa", 
{  
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_getNearestTable"];

    [_getNearestTable] remoteExec ["sebs_briefing_table_fnc_clearTable", 0, _getNearestTable];
    missionNamespace setVariable ["isSatTableOn" + _objectNetID, false, true];

},
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_getNearestTable"];

    missionNamespace getVariable ["isSatTableOn" + _objectNetID, false] && !(missionNamespace getVariable ["isGenerating" + _objectNetID, false])
}, {}, [_objectNetID, _getNearestTable], [0,-1.35,0.37], 1] call ace_interact_menu_fnc_createAction;



private _settingResolution = ["terrainResolution", _text_Setting_Resolution_Ace_DisplayName, "",
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_Resolution_Hint_Current"];

    private _resolution = missionNamespace getVariable ["terrainResolution" + _objectNetID, 25];
    hint format [_text_Setting_Resolution_Hint_Current, (str _resolution + "%")];
}, { true },
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_Resolution_Hint_Current", "_text_Setting_Resolution_Hint_Updated", "_text_Setting_Resolution_Ace_DisplayName_Sub"];

    private _actions = [];

    private _set25 = ["set25", (format [_text_Setting_Resolution_Ace_DisplayName_Sub, "25%"]), "",
    {
        params ["_target", "_caller", "_arguments"];
        _arguments params ["_objectNetID", "_text_Setting_Resolution_Hint_Updated"];

        hint format [_text_Setting_Resolution_Hint_Updated, "25%"];
        missionNamespace setVariable ["terrainResolution" + _objectNetID, 25, true];

    }, { true }, {}, [_objectNetID, _text_Setting_Resolution_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;


    private _set50 = ["set25", (format [_text_Setting_Resolution_Ace_DisplayName_Sub, "50%"]), "",
    {
        params ["_target", "_caller", "_arguments"];
        _arguments params ["_objectNetID", "_text_Setting_Resolution_Hint_Updated"];

        hint format [_text_Setting_Resolution_Hint_Updated, "50%"];
        missionNamespace setVariable ["terrainResolution" + _objectNetID, 50, true];

    }, { true }, {}, [_objectNetID, _text_Setting_Resolution_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;


    private _set75 = ["set75", (format [_text_Setting_Resolution_Ace_DisplayName_Sub, "75%"]), "",
    {
        params ["_target", "_caller", "_arguments"];
        _arguments params ["_objectNetID", "_text_Setting_Resolution_Hint_Updated"];

        hint format [_text_Setting_Resolution_Hint_Updated, "75%"];
        missionNamespace setVariable ["terrainResolution" + _objectNetID, 75, true];

    }, { true }, {}, [_objectNetID, _text_Setting_Resolution_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;


    private _set100 = ["set100", (format [_text_Setting_Resolution_Ace_DisplayName_Sub, "100%"]), "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_Resolution_Hint_Updated"];

       hint format [_text_Setting_Resolution_Hint_Updated, "100%"];
       missionNamespace setVariable ["terrainResolution" + _objectNetID, 100, true];

    }, { true }, {}, [_objectNetID, _text_Setting_Resolution_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    _actions pushBack [_set25, [], _target];
    _actions pushBack [_set50, [], _target];
    _actions pushBack [_set75, [], _target];
    _actions pushBack [_set100, [], _target];

    _actions
}, [_objectNetID, _text_Setting_Resolution_Hint_Current, _text_Setting_Resolution_Hint_Updated, _text_Setting_Resolution_Ace_DisplayName_Sub], [0,-1.38,0.34], 1] call ace_interact_menu_fnc_createAction;



private _settingHeight = ["terrainHeight", _text_Setting_Height_Ace_DisplayName, "",
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_Height_Ace_DisplayName_Sub_Up", "_text_Setting_Height_Ace_DisplayName_Sub_Down", "_text_Setting_Height_Hint_Current"];

    private _height = missionNamespace getVariable ["zPosBlocks" + _objectNetID, -0.1];
    hint format [_text_Setting_Height_Hint_Current, _height];
}, { true },
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_Height_Ace_DisplayName_Sub_Up", "_text_Setting_Height_Ace_DisplayName_Sub_Down", "_text_Setting_Height_Hint_Current", "_text_Setting_Height_Hint_Updated"];

    private _actions = [];

    private _moveUP = ["moveUP", _text_Setting_Height_Ace_DisplayName_Sub_Up, "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_Height_Ace_DisplayName_Sub_Up", "_text_Setting_Height_Ace_DisplayName_Sub_Down", "_text_Setting_Height_Hint_Current", "_text_Setting_Height_Hint_Updated"];

       private _currentHeight = missionNamespace getVariable ["zPosBlocks" + _objectNetID, 0];
       missionNamespace setVariable ["zPosBlocks" + _objectNetID, (_currentHeight + 0.1), true];
       private _updatedHeight = missionNamespace getVariable ["zPosBlocks" + _objectNetID, 0];

       hint format [_text_Setting_Height_Hint_Updated, (str _updatedHeight), (str _currentHeight)];
    }, { true }, {}, [_objectNetID, _text_Setting_Height_Ace_DisplayName_Sub_Up, _text_Setting_Height_Ace_DisplayName_Sub_Down, _text_Setting_Height_Hint_Current, _text_Setting_Height_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    private _moveDOWN = ["moveDOWN", _text_Setting_Height_Ace_DisplayName_Sub_Down, "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_Height_Ace_DisplayName_Sub_Up", "_text_Setting_Height_Ace_DisplayName_Sub_Down", "_text_Setting_Height_Hint_Current", "_text_Setting_Height_Hint_Updated"];

       private _currentHeight = missionNamespace getVariable ["zPosBlocks" + _objectNetID, 0];
       missionNamespace setVariable ["zPosBlocks" + _objectNetID, (_currentHeight - 0.1), true];
       private _updatedHeight = missionNamespace getVariable ["zPosBlocks" + _objectNetID, 0];

       hint format [_text_Setting_Height_Hint_Updated, (str _updatedHeight), (str _currentHeight)];
    }, { true }, {}, [_objectNetID, _text_Setting_Height_Ace_DisplayName_Sub_Up, _text_Setting_Height_Ace_DisplayName_Sub_Down, _text_Setting_Height_Hint_Current, _text_Setting_Height_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    _actions pushBack [_moveUP, [], _target];
    _actions pushBack [_moveDOWN, [], _target];

    _actions
}, [_objectNetID, _text_Setting_Height_Ace_DisplayName_Sub_Up, _text_Setting_Height_Ace_DisplayName_Sub_Down, _text_Setting_Height_Hint_Current, _text_Setting_Height_Hint_Updated], [0,-1.41,0.31], 1] call ace_interact_menu_fnc_createAction;



private _settingType = ["terrainType", _text_Setting_TerrainType_Ace_DisplayName, "",
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_TerrainType_Ace_DisplayName_Sub_Flat", "_text_Setting_TerrainType_Ace_DisplayName_Sub_3D", "_text_Setting_TerrainType_Hint_Current"];

    private _type = missionNamespace getVariable ["type" + _objectNetID, "Flat"];
    hint format [_text_Setting_TerrainType_Hint_Current, _type];
}, { true },
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_TerrainType_Ace_DisplayName_Sub_Flat", "_text_Setting_TerrainType_Ace_DisplayName_Sub_3D", "_text_Setting_TerrainType_Hint_Current", "_text_Setting_TerrainType_Hint_Updated"];

    private _actions = [];

    private _flat = ["flat", _text_Setting_TerrainType_Ace_DisplayName_Sub_Flat, "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_TerrainType_Ace_DisplayName_Sub_Flat", "_text_Setting_TerrainType_Ace_DisplayName_Sub_3D", "_text_Setting_TerrainType_Hint_Current", "_text_Setting_TerrainType_Hint_Updated"];

       private _currentType = missionNamespace getVariable ["type" + _objectNetID, "3D"];
       missionNamespace setVariable ["type" + _objectNetID, "Flat", true];
       private _updatedType = missionNamespace getVariable ["type" + _objectNetID, "3D"];

       hint format [_text_Setting_TerrainType_Hint_Updated, _updatedType, _currentType];
    }, { true }, {}, [_objectNetID, _text_Setting_TerrainType_Ace_DisplayName_Sub_Flat, _text_Setting_TerrainType_Ace_DisplayName_Sub_3D, _text_Setting_TerrainType_Hint_Current, _text_Setting_TerrainType_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    private _3D = ["3D", _text_Setting_TerrainType_Ace_DisplayName_Sub_3D, "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_TerrainType_Ace_DisplayName_Sub_Flat", "_text_Setting_TerrainType_Ace_DisplayName_Sub_3D", "_text_Setting_TerrainType_Hint_Current", "_text_Setting_TerrainType_Hint_Updated"];

       private _currentType = missionNamespace getVariable ["type" + _objectNetID, "3D"];
       missionNamespace setVariable ["type" + _objectNetID, "3D", true];
       private _updatedType = missionNamespace getVariable ["type" + _objectNetID, "3D"];

       hint format [_text_Setting_TerrainType_Hint_Updated, _updatedType, _currentType];
    }, { true }, {}, [_objectNetID, _text_Setting_TerrainType_Ace_DisplayName_Sub_Flat, _text_Setting_TerrainType_Ace_DisplayName_Sub_3D, _text_Setting_TerrainType_Hint_Current, _text_Setting_TerrainType_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    _actions pushBack [_flat, [], _target];
    _actions pushBack [_3D, [], _target];

    _actions
}, [_objectNetID, _text_Setting_TerrainType_Ace_DisplayName_Sub_Flat, _text_Setting_TerrainType_Ace_DisplayName_Sub_3D, _text_Setting_TerrainType_Hint_Current, _text_Setting_TerrainType_Hint_Updated], [0,-1.44,0.28], 1] call ace_interact_menu_fnc_createAction;



private _settingMarkerSize = ["markerSize", _text_Setting_MarkerSize_Ace_DisplayName, "",
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Current"];

    private _markerSize = missionNamespace getVariable ["markerSize" + _objectNetID, [250,250]];
    _markerSize = (str (_markerSize select 0)) + "x" + (str (_markerSize select 1));
    hint format [_text_Setting_MarkerSize_Hint_Current, _markerSize];
}, { true },
{
    params ["_target", "_caller", "_arguments"];
    _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Current", "_text_Setting_MarkerSize_Hint_Updated", "_text_Setting_MarkerSize_Ace_DisplayName_Sub"];

    private _actions = [];

    private _set50 = ["set50", (format [_text_Setting_MarkerSize_Ace_DisplayName_Sub, "50x50"]), "",
    {
        params ["_target", "_caller", "_arguments"];
        _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Updated"];

        hint format [_text_Setting_MarkerSize_Hint_Updated, "50x50"];
        missionNamespace setVariable ["markerSize" + _objectNetID, [50,50], true];

    }, { true }, {}, [_objectNetID, _text_Setting_MarkerSize_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;


    private _set100 = ["set100", (format [_text_Setting_MarkerSize_Ace_DisplayName_Sub, "100x100"]), "",
    {
        params ["_target", "_caller", "_arguments"];
        _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Updated"];

        hint format [_text_Setting_MarkerSize_Hint_Updated, "100x100"];
        missionNamespace setVariable ["markerSize" + _objectNetID, [100,100], true];

    }, { true }, {}, [_objectNetID, _text_Setting_MarkerSize_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;


    private _set250 = ["set250", (format [_text_Setting_MarkerSize_Ace_DisplayName_Sub, "250x250"]), "",
    {
        params ["_target", "_caller", "_arguments"];
        _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Updated"];

        hint format [_text_Setting_MarkerSize_Hint_Updated, "250x250"];
        missionNamespace setVariable ["markerSize" + _objectNetID, [250,250], true];

    }, { true }, {}, [_objectNetID, _text_Setting_MarkerSize_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;


    private _set500 = ["set500", (format [_text_Setting_MarkerSize_Ace_DisplayName_Sub, "500x500"]), "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Updated"];

       hint format [_text_Setting_MarkerSize_Hint_Updated, "500x500"];
       missionNamespace setVariable ["markerSize" + _objectNetID, [500,500], true];

    }, { true }, {}, [_objectNetID, _text_Setting_MarkerSize_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    private _set1000 = ["set1000", (format [_text_Setting_MarkerSize_Ace_DisplayName_Sub, "1000x1000"]), "",
    {
       params ["_target", "_caller", "_arguments"];
       _arguments params ["_objectNetID", "_text_Setting_MarkerSize_Hint_Updated"];

       hint format [_text_Setting_MarkerSize_Hint_Updated, "1000x1000"];
       missionNamespace setVariable ["markerSize" + _objectNetID, [1000,1000], true];

    }, { true }, {}, [_objectNetID, _text_Setting_MarkerSize_Hint_Updated], [0,0,0], 1] call ace_interact_menu_fnc_createAction;

    _actions pushBack [_set50, [], _target];
    _actions pushBack [_set100, [], _target];
    _actions pushBack [_set250, [], _target];
    _actions pushBack [_set500, [], _target];
    _actions pushBack [_set1000, [], _target];

    _actions
}, [_objectNetID, _text_Setting_MarkerSize_Hint_Current, _text_Setting_MarkerSize_Hint_Updated, _text_Setting_MarkerSize_Ace_DisplayName_Sub], [0,-1.47,0.25], 1] call ace_interact_menu_fnc_createAction;



[this, 0, [], _generateTerrain, true] call ace_interact_menu_fnc_addActionToObject;
[this, 0, [], _clearTerrain, true] call ace_interact_menu_fnc_addActionToObject;
[this, 0, [], _settingResolution, true] call ace_interact_menu_fnc_addActionToObject;
[this, 0, [], _settingHeight, true] call ace_interact_menu_fnc_addActionToObject;
[this, 0, [], _settingType, true] call ace_interact_menu_fnc_addActionToObject;
[this, 0, [], _settingMarkerSize, true] call ace_interact_menu_fnc_addActionToObject;