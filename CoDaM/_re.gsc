
//
///////////////////////////////////////////////////////////////////////////////
main()
{
	codam\utils::_debug( "I'M IN C_RE" );

	// First time in, call the CoDaM initialization function with
	// ... the gametype registration function (which initializes
	// ... gametype-specific callbacks) and the actual game type string
	register = codam\init::main( ::gtRegister, "re", "retrieval" );

	if ( !isdefined( game[ "re_attackers" ] ) )
		game[ "re_attackers" ] = "allies";
	if ( !isdefined( game[ "re_defenders" ] ) )
		game[ "re_defenders" ] = "axis";

	if ( !isdefined( game[ "re_attackers_obj_text" ] ) )
		game[ "re_attackers_obj_text" ] =
					&"RE_ATTACKERS_OBJ_TEXT_GENERIC";
	if ( !isdefined( game[ "re_defenders_obj_text" ] ) )
		game[ "re_defenders_obj_text" ] =
					&"RE_DEFENDERS_OBJ_TEXT_GENERIC";

	game[ "headicon_carrier" ] = "gfx/hud/headicon@re_objcarrier.tga";

	level.roundbased = true;		// This is a round-based GT
	level.roundstarted = false;
	level.roundended = false;

	level.numobjectives = 0;
	level.objectives_done = 0;
	level.hudcount = 0;
	level.barsize = 288;

	if ( codam\utils::getVar( "scr", "switchroles", "bool", 1|2, false ) )
	{
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_retrieval_spawn_allied", "random", "axis" );
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_retrieval_spawn_axis", "random", "allies" );
	}
	else
	{
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_retrieval_spawn_allied", "random", "allies" );
		[[ level.gtd_call ]]( "registerSpawn",
			"mp_retrieval_spawn_axis", "random", "axis" );
	}

	// Make sure players aren't holding any objects from previous round
	players = getentarray( "player", "classname" );
	for ( i = 0; i < players.size; i++ )
		players[ i ].objs_held = 0;

	//get the minefields
	level.minefield = getentarray( "minefield", "targetname" );
	if ( !isdefined( level.minefield ) )
		level.minefield = [];
	hurtTrigs = getentarray( "trigger_hurt", "classname" );
	for ( i = 0; i < hurtTrigs.size; i++ )
		level.minefield[ level.minefield.size ] = hurtTrigs[ i ];
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
gtRegister( register, post )
{
	// Since CoDaM treats the first registration of a callback as the
	// ... "default" call, must ensure that gametype-specific functions
	// ... are registered first during Init.

	if ( isdefined( post ) )
		return;

	// Script-level	callbacks
	[[ register ]](	   "StartGameType", ::StartGameType );
	[[ register ]](	   "PlayerConnect", codam\callbacks::PlayerConnect );
	[[ register ]](	"PlayerDisconnect", codam\callbacks::PlayerDisconnect );
	[[ register ]](	    "PlayerDamage", codam\callbacks::PlayerDamage );
	[[ register ]](	    "PlayerKilled", codam\callbacks::PlayerKilled );

	// Game-type callbacks
	[[ register ]](   "finishPlayerKilled",
				codam\callbacks::finishPlayerKilled );
	[[ register ]](	        "gt_startGame",
				codam\GameTypes\_sd::startGame );
	[[ register ]](	      "gt_autoBalance",
				codam\GameTypes\_sd::autoBalance );
	[[ register ]](	      "gt_checkUpdate",
				codam\GameTypes\_sd::checkUpdate );
	[[ register ]](	       "gt_startRound",
				codam\GameTypes\_sd::startRound );
	[[ register ]](	        "gt_objective", ::retrieval );
	[[ register ]](            "gt_endMap",
				codam\GameTypes\_sd::endMap );
	[[ register ]](          "gt_endRound",
				codam\GameTypes\_sd::endRound );
	[[ register ]](          "gt_respawn",
				codam\GameTypes\_tdm::respawn );
	[[ register ]](       "gt_spawnPlayer",
				codam\GameTypes\_tdm::spawnPlayer );
	[[ register ]](    "gt_spawnSpectator",
				codam\GameTypes\_tdm::spawnSpectator );
	[[ register ]]( "gt_spawnIntermission",
				codam\GameTypes\_tdm::spawnIntermission );
	[[ register ]](       "gt_menuHandler",
				codam\GameTypes\_sd::menuHandler );
	[[ register ]](  "gt_timeLimitReached",
				codam\GameTypes\_sd::timeLimitReached );
	[[ register ]]( "gt_scoreLimitReached",
				codam\GameTypes\_sd::scoreLimitReached );
	[[ register ]]( "gt_roundLimitReached",
				codam\GameTypes\_sd::roundLimitReached );
	[[ register ]](   "gt_checkMatchStart",
				codam\GameTypes\_sd::checkMatchStart );
	[[ register ]](  "gt_updateTeamStatus",
				codam\GameTypes\_sd::updateTeamStatus );
	[[ register ]](          "gt_roundCam",
				codam\GameTypes\_sd::roundCam );
	[[ register ]](       "gt_saveWeapons",
				codam\GameTypes\_sd::saveWeapons );
	[[ register ]](     "gt_dropObjective", ::dropObjective );
	[[ register ]](      "gt_roundStarted",
				codam\GameTypes\_sd::roundStarted );

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
StartGameType( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1,	b2, b2,	b4, b5,	b6, b7,	b8, b9 )
{
	// Call	the CoDaM initialization function without any args to
	// continue with framework/custom mods initialization.
	codam\init::main();

	// If this is a	fresh map start	...
	if( !isdefined( game[ "gamestarted" ] ) )
	{
		if ( level.ham_shortversion != "1.1" )
		{
			makeCvarServerInfo( "ui_re_timelimit", "0" );
			makeCvarServerInfo( "ui_re_scorelimit", "10" );
			makeCvarServerInfo( "ui_re_roundlimit", "0" );

			game[ "menu_serverinfo" ] = "serverinfo_" +
							level.ham_g_gametype;
			precacheMenu( game[ "menu_serverinfo" ] );
		}

		precacheString(	&"RE_U_R_CARRYING" );
		precacheString(	&"RE_U_R_CARRYING_GENERIC" );
		precacheString(	&"RE_PICKUP_AXIS_ONLY_GENERIC" );
		precacheString(	&"RE_PICKUP_AXIS_ONLY" );
		precacheString(	&"RE_PICKUP_ALLIES_ONLY_GENERIC" );
		precacheString(	&"RE_PICKUP_ALLIES_ONLY" );
		precacheString(	&"RE_OBJ_PICKED_UP_GENERIC" );
		precacheString(	&"RE_OBJ_PICKED_UP_GENERIC_NOSTARS" );
		precacheString(	&"RE_OBJ_PICKED_UP" );
		precacheString(	&"RE_OBJ_PICKED_UP_NOSTARS" );
		precacheString(	&"RE_PRESS_TO_PICKUP" );
		precacheString(	&"RE_PRESS_TO_PICKUP_GENERIC" );
		precacheString(	&"RE_OBJ_TIMEOUT_RETURNING" );
		precacheString(	&"RE_OBJ_DROPPED" );
		precacheString(	&"RE_OBJ_DROPPED_DEFAULT" );
		precacheString(	&"RE_OBJ_INMINES_MULTIPLE" );
		precacheString(	&"RE_OBJ_INMINES_GENERIC" );
		precacheString(	&"RE_OBJ_INMINES" );
		precacheString(	&"RE_ATTACKERS_OBJ_TEXT_GENERIC" );
		precacheString(	&"RE_DEFENDERS_OBJ_TEXT_GENERIC" );
		precacheString(	&"RE_ROUND_DRAW" );
		precacheString(	&"RE_MATCHSTARTING" );
		precacheString(	&"RE_MATCHRESUMING" );
		precacheString(	&"RE_TIMEEXPIRED" );
		precacheString(	&"RE_ELIMINATED_ALLIES"	);
		precacheString(	&"RE_ELIMINATED_AXIS" );
		precacheString(	&"RE_OBJ_CAPTURED_GENERIC" );
		precacheString(	&"RE_OBJ_CAPTURED_ALL" );
		precacheString(	&"RE_OBJ_CAPTURED" );
		precacheString(	&"RE_RETRIEVAL"	);
		precacheString(	&"RE_ALLIES" );
		precacheString(	&"RE_AXIS" );
		precacheString(	&"RE_OBJ_ARTILLERY_MAP"	);
		precacheString(	&"RE_OBJ_PATROL_LOGS" );
		precacheString(	&"RE_OBJ_CODE_BOOK" );
		precacheString(	&"RE_OBJ_FIELD_RADIO" );
		precacheString(	&"RE_OBJ_SPY_RECORDS" );
		precacheString(	&"RE_OBJ_ROCKET_SCHEDULE" );
		precacheString(	&"RE_OBJ_CAMP_RECORDS" );

		precacheShader(	"gfx/hud/hud@objectivegoal.tga"	);
		precacheShader(	"gfx/hud/hud@objectivegoal_up.tga" );
		precacheShader(	"gfx/hud/hud@objectivegoal_down.tga" );
		precacheShader(	"gfx/hud/objective.tga"	);
		precacheShader(	"gfx/hud/objective_up.tga" );
		precacheShader(	"gfx/hud/objective_down.tga" );

		precacheHeadIcon( game[	"headicon_carrier" ] );
		precacheStatusIcon( game[ "headicon_carrier" ] );

		[[ level.gtd_call ]]( "scoreboard" );
	}

	// Should team roles be switched?
	if ( codam\utils::getVar( "scr", "switchroles", "bool", 1|2, false ) )
	{
		_x = game[ "re_attackers" ];
		game[ "re_attackers" ] = game[ "re_defenders" ];
		game[ "re_defenders" ] = _x;
	}

	// Last call to CoDaM init to cause any last-minutes framework to
	// start.
	codam\init::main();

	game[ "gamestarted" ] =	true;
	[[ level.gtd_call ]]( "setClientNameMode", "auto_change" );
	thread [[ level.gtd_call ]]( "gt_startGame" );
	return;
}

//
///////////////////////////////////////////////////////////////////////////////
dropObjective( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	if ( !isPlayer( self ) ||
	     !isdefined( self.objs_held ) || ( self.objs_held < 1 ) )
		return;

	for ( i = 0; i < level.numobjectives + 1; i++ )
	{
		if ( isdefined( self.hasobj[ i ] ) )
		{
			//if (self isonground())
			//{
			//	println ("PLAYER KILLED ON THE GROUND");
				self.hasobj[ i ] thread drop_objective_on_disconnect_or_death( self );
			//}
			//else
			//{
			//	println ("PLAYER KILLED NOT ON THE GROUND");
			//	self.hasobj[ i ] thread drop_objective_on_disconnect_or_death( self.origin, "trace" );
			//}
		}
	}

	return;
}

//
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

retrieval( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
			b0, b1, b2, b3, b4, b5, b6, b7, b8, b9 )
{
	level.retrieval_objective = getentarray("retrieval_objective","targetname");
	if ( !isdefined( level.retrieval_objective ) ||
	     ( level.retrieval_objective.size < 1 ) )
	{
		codam\utils::_debug( "^1ERROR^7: map is missing retrieval objectives" );
		[[ level.gtd_call ]]( "exitLevel", false );
		wait( 9999 );
	}

	for(i = 0; i < level.retrieval_objective.size; i++)
	{
		level.retrieval_objective[i] thread retrieval_spawn_objective();
		level.retrieval_objective[i] thread objective_think("objective");
	}
}

objective_think(type)
{
	level.numobjectives = (level.numobjectives + 1);
	num = level.numobjectives;

	objective_add(num, "current", self.origin, "gfx/hud/objective.tga");
	self.objnum = (num);

	if (type == "objective")
	{
		level.hudcount++;
		self.hudnum = level.hudcount;
		objective_position(num, self.origin);
		if (!codam\utils::getVar( "scr", "showcarrier", "bool", 1|2, false ))
		{
			while (1)
			{
				self waittill ("picked up");
				objective_team(num,game["re_attackers"]);

				self waittill ("dropped");
				objective_team(num,"none");
			}
		}
	}
	else
	if (type == "goal")
	{
		objective_icon (num,"gfx/hud/hud@objectivegoal.tga");
		//if (!codam\utils::getVar( "scr", "showcarrier", "bool", 1|2, false ))
		//	objective_team(num,game["re_attackers"]);
	}
}

retrieval_spawn_objective()
{
	targeted = getentarray (self.target,"targetname");
	for (i=0;i<targeted.size;i++)
	{
		if (targeted[i].classname == "mp_retrieval_objective")
			spawnloc = maps\MP\_utility::add_to_array(spawnloc, targeted[i]);
		else
		if (targeted[i].classname == "trigger_use")
			self.trigger = (targeted[i]);
		else
		if (targeted[i].classname == "trigger_multiple")
		{
			self.goal = (targeted[i]);
			self.goal thread objective_think("goal");
		}
	}

	if ( (!isdefined (spawnloc)) || (spawnloc.size < 1) )
	{
		maps\mp\_utility::error("retrieval_objective does not target any mp_retrieval_objectives");
		return;
	}
	if (!isdefined (self.trigger))
	{
		maps\mp\_utility::error("retrieval_objective does not target a trigger_use");
		return;
	}
	if (!isdefined (self.goal))
	{
		maps\mp\_utility::error("retrieval_objective trigger_use does not target a trigger_multiple");
		return;
	}

	//move objective to random spot
	rand = randomint(spawnloc.size);
	if (spawnloc.size > 2)
	{
		if (isdefined(game["last_objective_pos"]))
		while (rand == game["last_objective_pos"])
			rand = randomint(spawnloc.size);
		game["last_objective_pos"] = rand;
	}
	self.origin = (spawnloc[rand].origin);
	self.startorigin = self.origin;
	self.startangles = self.angles;
	self.trigger.origin = (spawnloc[rand].origin);
	self.trigger.startorigin = self.trigger.origin;

	self thread retrieval_think();

	//Set hintstring on the objectives trigger
	wait 0;//required for level script to run and load the level.obj array
	if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
		self.trigger setHintString (&"RE_PRESS_TO_PICKUP",level.obj[self.script_objective_name]);
	else
		self.trigger setHintString (&"RE_PRESS_TO_PICKUP_GENERIC");
}

retrieval_think() //each objective model runs this to find it's trigger and goal
{
	if (isdefined (self.objnum))
		objective_position(self.objnum,self.origin);

	while (1)
	{
		self.trigger waittill ("trigger",other);

		//if(!game["matchstarted"])
		//	return;

		if ( (isPlayer(other)) && (other.pers["team"] == game["re_attackers"]) )
		{
			if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
			{
				if (!codam\utils::getVar( "scr", "showcarrier", "bool", 1|2, false ))
					[[ level.gtd_call ]]( "announce", &"RE_OBJ_PICKED_UP_NOSTARS",level.obj[self.script_objective_name]);
				else
					[[ level.gtd_call ]]( "announce", &"RE_OBJ_PICKED_UP",level.obj[self.script_objective_name]);
			}
			else
			{
				if (!codam\utils::getVar( "scr", "showcarrier", "bool", 1|2, false ))
					[[ level.gtd_call ]]( "announce", &"RE_OBJ_PICKED_UP_GENERIC_NOSTARS");
				else
					[[ level.gtd_call ]]( "announce", &"RE_OBJ_PICKED_UP_GENERIC");
			}
			self playsound ("re_pickup_paper");
			self thread hold_objective(other);
			other.hasobj[self.objnum] = self;
			//println ("SETTING HASOBJ[" + self.objnum + "] as the " + self.script_objective_name);
			other.objs_held++;
			/*
			println ("PUTTING OBJECTIVE " + self.objnum + " ON THE PLAYER ENTITY");
			objective_onEntity(self.objnum, other);
			*/
			other thread display_holding_obj(self);
			return;

		}
		else if ( (isPlayer(other)) && (other.pers["team"] == game["re_defenders"]) )
		{
			if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
			{
				if ( game["re_attackers"] == "allies" )
					other thread client_print(self, &"RE_PICKUP_ALLIES_ONLY",level.obj[self.script_objective_name]);
				else if ( game["re_attackers"] == "axis" )
					other thread client_print(self, &"RE_PICKUP_AXIS_ONLY",level.obj[self.script_objective_name]);
			}
			else
			{
				if ( game["re_attackers"] == "allies" )
					other thread client_print(self, &"RE_PICKUP_ALLIES_ONLY_GENERIC");
				else if ( game["re_attackers"] == "axis" )
					other thread client_print(self, &"RE_PICKUP_AXIS_ONLY_GENERIC");
			}
		}
		else
			wait (.5);
	}
}

hold_objective(player) //the objective model runs this to be held by 'player'
{
	self endon ("completed");
	self endon ("dropped");
	team = player.sessionteam;
	self hide();

	[[ level.gtd_call ]]( "logPrint", "action", player, game[ "re_attackers" ], player.name, "re_pickup" );

	if (player.pers["team"] == game["re_attackers"])

	self.trigger triggerOff();
	player playLocalSound ("re_pickup_paper");
	self notify ("picked up");

	//println ("PUTTING OBJECTIVE " + self.objnum + " ON THE PLAYER ENTITY");
	player.statusicon = game["headicon_carrier"];
	objective_onEntity(self.objnum, player);

	self thread objective_carrier_atgoal_wait(player);
	self thread holduse(player);
	self thread pressuse_notify(player);

	player.headicon = game["headicon_carrier"];
	if (!codam\utils::getVar( "scr", "showcarrier", "bool", 1|2, false ))
		player.headiconteam = (game["re_attackers"]);
	else
		player.headiconteam = "none";
}

objective_carrier_atgoal_wait(player)
{
	self endon ("dropped");
	while (1)
	{
		self.goal waittill ("trigger",other);
		if ( (other == player) && (isPlayer(player)) && (player.pers["team"] == game["re_attackers"]) )
		{
			//player.pers["score"] += 3;
			//player.score = player.pers["score"];
			level.objectives_done++;

			objective_delete(self.objnum);
			self notify ("completed");

			//org = (player.origin);
			self thread drop_objective(player,1);

			objective_delete(self.objnum);

			self delete();

			if (level.objectives_done < level.retrieval_objective.size)
			{
				return;
			}
			else
			{
				if(isdefined (self.goal.target))
					level.goalcam = getent(self.goal.target, "targetname");
				else
					level.goalcam = spawn ("script_origin",(self.goal.origin + (0,0,100)) );

				if (isdefined (level.goalcam.target))
				{
					goalcam_focus = getent (level.goalcam.target,"targetname");
					level.goalcam.angles = vectortoangles(goalcam_focus.origin - level.goalcam.origin);
				}
				else
					level.goalcam.angles = vectortoangles(self.goal.origin - level.goalcam.origin);

				level notify( "end_round", &"RE_OBJ_CAPTURED_ALL", game[ "re_attackers" ], level.goalcam );
				return;
			}
		}
		else
		{
			wait .05;
		}
	}
}

drop_objective(player,option)
{
	if (isPlayer(player))
	{
		num = (16 - (self.hudnum));
		if (isdefined (self.objs_held))
		{
			if (self.objs_held > 0)
			{
				for (i=0;i<(level.numobjectives + 1);i++)
				{
					if (isdefined (self.hasobj[i]))
					{
						//if (self isonground())
							self.hasobj[i] thread drop_objective_on_disconnect_or_death(self);
						//else
						//	self.hasobj[i] thread drop_objective_on_disconnect_or_death(self.origin, "trace");
					}
				}
			}
		}

		if ( (isdefined (player.hudelem)) && (isdefined (player.hudelem[num])) )
			player.hudelem[num] destroy();
	}

	//if (isdefined (loc))
	loc = (player.origin + (0,0,25));

	if ( (isdefined (option)) && (option == 1) )
	{
		player.objs_held--;
		if ( (isdefined (self.objnum)) && (isdefined (player.hasobj[self.objnum])) )
			player.hasobj[self.objnum] = undefined;
		else
		println ("#### " + self.objnum + "UNDEFINED");

		objective_delete(self.objnum);

		[[ level.gtd_call ]]( "logPrint", "action", player, game[ "re_attackers" ], player.name, "re_capture" );

		if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_CAPTURED", level.obj[ self.script_objective_name ] );
		else
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_CAPTURED_GENERIC" );

		if (isdefined (self.trigger))
			self.trigger delete();

		if ( (isPlayer(player)) && (player.objs_held < 1) )
		{
			if (level.drawfriend == 1)
			{
				if (isPlayer(player))
				if(player.pers["team"] == "allies")
				{
					player.headicon = game["headicon_allies"];
					player.headiconteam = "allies";
				}
				else if(player.pers["team"] == "axis")
				{
					player.headicon = game["headicon_axis"];
					player.headiconteam = "axis";
				}
				else
				{
					player.statusicon = "";
					player.headicon = "";
				}
			}
			else
			{
				if (isPlayer(player))
				{
					player.statusicon = "";
					player.headicon = "";
				}
			}
		}
	}
	else
	{
		/*
		if (player isOnGround())
		{
			trace = bulletTrace(loc, (loc-(0,0,5000)), false, undefined);
			end_loc = trace["position"]; //where the ground under the player is
		}
		else
		{
			println ("PLAYER IS ON GROUND - SKIPPING TRACE");
			end_loc = player.origin;
		}
		*/
		//CHAD
		plant = player maps\mp\_utility::getPlant();
		end_loc = plant.origin;

		if (distance(loc,end_loc) > 0 )
		{
			self.origin = (loc);
			self.angles = plant.angles;
			self show();
			speed = (distance(loc,end_loc) / 250);
			if (speed > 0.4)
			{
				self moveto(end_loc,speed,.1,.1);
				self waittill ("movedone");
				self.trigger.origin = (end_loc);
			}
			else
			{
				self.origin = end_loc;
				self.angles = plant.angles;
				self show();
				self.trigger.origin = (end_loc);
			}
		}
		else
		{
			self.origin = end_loc;
			self.angles = plant.angles;
			self show();
			self.trigger.origin = (end_loc);
		}

		//check if it's in a minefield
		In_Mines = 0;
		for (i=0;i<level.minefield.size;i++)
		{
			if (self istouching(level.minefield[i]))
			{
				In_Mines = 1;
				break;
			}
		}

		if (In_Mines == 1)
		{
			if (player.objs_held > 1)
			{	//IF A PLAYER HOLDS 2 OR MORE OBJECTIVES AND DROPS ONLY ONE INTO THE MINEFIELD
				//THEN THIS WILL STILL SAY "MULTIPLE OBJECTIVES..." BUT A PLAYER SHOULD NEVER
				//BE ABOVE A MINEFIELD IN ONE OF THE SHIPPED MAPS SO I'LL LEAVE IT FOR NOW
				if ( (!isdefined (level.lastdropper)) || (level.lastdropper != player) )
				{
					level.lastdropper = player;
					[[ level.gtd_call ]]( "announce", &"RE_OBJ_INMINES_MULTIPLE");
				}
			}
			else
			{
				if ( (!isdefined (level.lastdropper)) || (level.lastdropper != player) )
				{
					level.lastdropper = player;
					if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
						[[ level.gtd_call ]]( "announce", &"RE_OBJ_INMINES",level.obj[self.script_objective_name]);
					else
						[[ level.gtd_call ]]( "announce", &"RE_OBJ_INMINES_GENERIC");
				}
			}
			self.trigger.origin = (self.trigger.startorigin);
			self.origin = (self.startorigin);
			self.angles = (self.startangles);
		}
		else
		{
			if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )

				[[ level.gtd_call ]]( "announce", &"RE_OBJ_DROPPED",level.obj[self.script_objective_name]);
			else
				[[ level.gtd_call ]]( "announce", &"RE_OBJ_DROPPED");
		}

		if (isPlayer(player))
		{
			if ( (isdefined (self.objnum)) && (isdefined (player.hasobj[self.objnum])) )
				player.hasobj[self.objnum] = undefined;
			else
				println ("#### " + self.objnum + "UNDEFINED");
			player.objs_held--;
		}

		if ( (isPlayer(player)) && (player.objs_held < 1) )
		{
			if (level.drawfriend == 1)
			{
				if (isPlayer(player))
				if(player.pers["team"] == "allies")
				{
					player.headicon = game["headicon_allies"];
					player.headiconteam = "allies";
				}
				else if(player.pers["team"] == "axis")
				{
					player.headicon = game["headicon_axis"];
					player.headiconteam = "axis";
				}
				else
				{
					player.statusicon = "";
					player.headicon = "";
				}
			}
			else
			{
				if (isPlayer(player))
				{
					player.statusicon = "";
					player.headicon = "";
				}
			}
		}

		if (self istouching (self.goal))
		{
			if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
				[[ level.gtd_call ]]( "announce", &"RE_OBJ_CAPTURED",level.obj[self.script_objective_name]);
			else
				[[ level.gtd_call ]]( "announce", &"RE_OBJ_CAPTURED_GENERIC");

			if (isdefined (self.trigger))
				self.trigger delete();

			if ( (isPlayer(player)) && (player.objs_held < 1) )
			{
				if (level.drawfriend == 1)
				{
					if (isPlayer(player))
					if(player.pers["team"] == "allies")
					{
						player.headicon = game["headicon_allies"];
						player.headiconteam = "allies";
					}
					else if(player.pers["team"] == "axis")
					{
						player.headicon = game["headicon_axis"];
						player.headiconteam = "axis";
					}
					else
					{
						player.statusicon = "";
						player.headicon = "";
					}
				}
				else
				{
					if (isPlayer(player))
					{
						player.statusicon = "";
						player.headicon = "";
					}
				}
			}

			//player.pers["score"] += 3;
			//player.score = player.pers["score"];
			level.objectives_done++;

			self notify ("completed");
			level thread clear_player_dropbar(player);

			objective_delete(self.objnum);
			self delete();

			if (level.objectives_done < level.retrieval_objective.size)
			{
				return;
			}
			else
			{
				level notify( "end_round", &"RE_OBJ_CAPTURED_ALL", game[ "re_attackers" ], undefined );
				return;
			}
		}

		self thread objective_timeout();
		self notify ("dropped");
		self thread retrieval_think();
	}
}

clear_player_dropbar(player)
{
	if (isdefined (player))
	{
		player.progressbackground destroy();
		player.progressbar destroy();
		player unlink();
		player.isusing = false;
	}
}

objective_timeout()
{
	self endon ("picked up");
	obj_timeout = codam\utils::getVar( "scr", "objtimer", "float",
							1|2, 60, 20, 120 );
	wait( obj_timeout );
	[[ level.gtd_call ]]( "announce", &"RE_OBJ_TIMEOUT_RETURNING",
								obj_timeout);
	self.trigger.origin = (self.trigger.startorigin);
	self.origin = (self.startorigin);
	self.angles = (self.startangles);
	objective_position(self.objnum,self.origin);
}

holduse(player)
{
	player endon ("death");
	self endon ("completed");
	self endon ("dropped");
	player.isusing = false;
	delaytime = .3;
	droptime = 2;
	barsize = 288;
	level.barincrement = (barsize / (20.0 * droptime));

	wait (1);

	while (isPlayer(player))
	{
		player waittill ("Pressed Use");
		if (player.isusing == true)
			continue;
		else
			player.isusing = true;

		player.currenttime = 0;
		while(player useButtonPressed() && (isalive (player)))
		{
			usetime = 0;
			while(isalive(player) && player useButtonPressed() && (usetime < delaytime))
			{
				wait .05;
				usetime = (usetime + .05);
			}

			if (!(player isOnGround()))
				continue;

			if (!( (isalive(player)) && (player useButtonPressed()) ) )
			{
				player unlink();
				continue;
			}
			else
			{
				if(!isdefined(player.progressbackground))
				{
					player.progressbackground = newClientHudElem(player);
					player.progressbackground.alignX = "center";
					player.progressbackground.alignY = "middle";
					player.progressbackground.x = 320;
					player.progressbackground.y = 385;
					player.progressbackground.alpha = 0.5;
				}
				player.progressbackground setShader("black", (level.barsize + 4), 12);
				progresstime = 0;
				progresslength = 0;

				spawned = spawn ("script_origin",player.origin);
				if (isdefined (spawned))
					player linkto(spawned);

				while(isalive(player) && player useButtonPressed() && (progresstime < droptime))
				{
					progresstime += 0.05;
					progresslength += level.barincrement;

					if(!isdefined(player.progressbar))
					{
						player.progressbar = newClientHudElem(player);
						player.progressbar.alignX = "left";
						player.progressbar.alignY = "middle";
						player.progressbar.x = (320 - (level.barsize / 2.0));
						player.progressbar.y = 385;
					}
					player.progressbar setShader("white", progresslength, 8);

					wait 0.05;
				}

				if(progresstime >= droptime)
				{
					if (isdefined (player.progressbackground))
						player.progressbackground destroy();
					if (isdefined (player.progressbar))
						player.progressbar destroy();

					self thread drop_objective(player);
					self notify ("dropped");
					player unlink();
					player.isusing = false;
					return;
				}
				else if(isalive(player))
				{
					player.progressbackground destroy();
					player.progressbar destroy();
				}
			}
		}
		player unlink();
		player.isusing = false;
		wait(.05);
	}
}

pressuse_notify(player)
{
	player endon ("death");
	self endon ("dropped");
	while (isPlayer(player))
	{
		if (player useButtonPressed())
			player notify ("Pressed Use");

		wait (.05);
	}
}

display_holding_obj(obj_ent)
{
	num = (16 - (obj_ent.hudnum));

	if (num > 16)
		return;

	offset = (150 + (obj_ent.hudnum * 15));

	self.hudelem[num] = newClientHudElem(self);
	self.hudelem[num].alignX = "right";
	self.hudelem[num].alignY = "middle";
	self.hudelem[num].x = 635;
	self.hudelem[num].y = (550-offset);

	if ( (isdefined (obj_ent.script_objective_name)) && (isdefined (level.obj[obj_ent.script_objective_name])) )
	{
		self.hudelem[num].label = (&"RE_U_R_CARRYING");
		self.hudelem[num] setText(level.obj[obj_ent.script_objective_name]);
	}
	else
		self.hudelem[num] setText (&"RE_U_R_CARRYING_GENERIC");
}

triggerOff()
{
	self.origin = (self.origin - (0,0,10000));
}

client_print(obj, text, s)
{
	num = (16 - (obj.hudnum));

	if (num > 16)
		return;

	self notify ("stop client print");
	self endon ("stop client print");

	//if ( (isdefined (self.hudelem)) && (isdefined (self.hudelem[num])) )
	//	self.hudelem[num] destroy();

	for (i=1;i<16;i++)
	{
		if ( (isdefined (self.hudelem)) && (isdefined (self.hudelem[i])) )
			self.hudelem[i] destroy();
	}

	self.hudelem[num] = newClientHudElem(self);
	self.hudelem[num].alignX = "center";
	self.hudelem[num].alignY = "middle";
	self.hudelem[num].x = 320;
	self.hudelem[num].y = 200;

	if (isdefined (s))
	{
		self.hudelem[num].label = text;
		self.hudelem[num] setText(s);
	}
	else
		self.hudelem[num] setText(text);

	wait 3;

	if ( (isdefined (self.hudelem)) && (isdefined (self.hudelem[num])) )
		self.hudelem[num] destroy();
}

drop_objective_on_disconnect_or_death(player)
{
	//CHAD
	/*
	if (isdefined (trace))
	{
		loc = (loc + (0,0,25));
		trace = bulletTrace(loc, (loc-(0,0,5000)), false, undefined);
		end_loc = trace["position"]; //where the ground under the player is
	}
	else
	{
		println ("PLAYER IS ON GROUND - SKIPPING TRACE");
		end_loc = loc;
	}
	*/

	plant = player maps\mp\_utility::getPlant();
	end_loc = plant.origin;

	if (distance(player.origin,end_loc) > 0 )
	{
		self.origin = (player.origin);
		self.angles = plant.angles;
		self show();
		speed = (distance(player.origin,end_loc) / 250);
		if (speed > 0.4)
		{
			self moveto(end_loc,speed,.1,.1);
			self waittill ("movedone");
			self.trigger.origin = (end_loc);
		}
		else
		{
			self.origin = end_loc;
			self.angles = plant.angles;
			self show();
			self.trigger.origin = (end_loc);
		}
	}
	else
	{
		self.origin = end_loc;
		self.angles = plant.angles;
		self show();
		self.trigger.origin = (end_loc);
	}

	//check if it's in a minefield
	In_Mines = 0;
	for (i=0;i<level.minefield.size;i++)
	{
		if (self istouching(level.minefield[i]))
		{
			In_Mines = 1;
			break;
		}
	}

	if (In_Mines == 1)
	{
		if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_INMINES",level.obj[self.script_objective_name]);
		else
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_INMINES_GENERIC");

		self.trigger.origin = (self.trigger.startorigin);
		self.origin = (self.startorigin);
		self.angles = (self.startangles);
	}
	else if (self istouching (self.goal))
	{
		if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_CAPTURED",level.obj[self.script_objective_name]);
		else
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_CAPTURED_GENERIC");

		if (isdefined (self.trigger))
			self.trigger delete();

		if ( (isPlayer(player)) && (player.objs_held < 1) )
		{
			if (level.drawfriend == 1)
			{
				if (isPlayer(player))
				if(player.pers["team"] == "allies")
				{
					player.headicon = game["headicon_allies"];
					player.headiconteam = "allies";
				}
				else if(player.pers["team"] == "axis")
				{
					player.headicon = game["headicon_axis"];
					player.headiconteam = "axis";
				}
				else
				{
					player.statusicon = "";
					player.headicon = "";
				}
			}
			else
			{
				if (isPlayer(player))
				{
					player.statusicon = "";
					player.headicon = "";
				}
			}
		}

		//player.pers["score"] += 3;
		//player.score = player.pers["score"];
		level.objectives_done++;

		self notify ("completed");
		level thread clear_player_dropbar(player);

		objective_delete(self.objnum);
		self delete();

		if (level.objectives_done < level.retrieval_objective.size)
		{
			return;
		}
		else
		{
			level notify( "end_round", &"RE_OBJ_CAPTURED_ALL", game[ "re_attackers" ], undefined );
			return;
		}
	}
	else
	{
		if ( (isdefined (self.script_objective_name)) && (isdefined (level.obj[self.script_objective_name])) )
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_DROPPED",level.obj[self.script_objective_name]);
		else
			[[ level.gtd_call ]]( "announce", &"RE_OBJ_DROPPED");
	}

	self thread objective_timeout();
	self notify ("dropped");
	self thread retrieval_think();
}

//
///////////////////////////////////////////////////////////////////////////////
