/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution
	name = "Revolutionaries"
	ID = F_REVOLUTION
	required_pref = ROLE_REV

	initroletype = /datum/role/rev_leader
	roletype = /datum/role/rev

	min_roles = 2
	max_roles = 2

	logo_state = "rev-logo"

	var/last_command_report = 0
	var/tried_to_add_revheads = 0

/datum/faction/revolution/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution/OnPostSetup()
	if(SSshuttle)
		SSshuttle.fake_recall = TRUE

	return ..()

/datum/faction/revolution/forgeObjectives()
	if(!..())
		return FALSE
	var/list/heads = get_living_heads()

	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/rp_rev/rev_obj = AppendObjective(/datum/objective/target/rp_rev, TRUE)
		if(rev_obj)
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Capture, convert or exile from station [head_mind.name], the [head_mind.assigned_role]. Assassinate if you have no choice."
	return TRUE

/datum/faction/revolution/proc/check_heads_victory()
	for(var/datum/role/rev_leader/R in members)
		var/turf/T = get_turf(R.antag.current)
		if(R.antag.current.stat != DEAD)
			var/mob/living/carbon/C = R.antag
			if(!C.handcuffed && T && is_station_level(T.z))
				return FALSE
	return TRUE

/datum/faction/revolution/check_win()
	var/win = IsSuccessful()
	if(config.continous_rounds)
		if(win && SSshuttle)
			SSshuttle.fake_recall = FALSE
		return FALSE

	if(win)
		return TRUE
	return FALSE

/datum/faction/revolution/custom_result()
	var/dat = ""
	if(IsSuccessful())
		var/dead_heads = 0
		var/alive_heads = 0
		for(var/datum/mind/head_mind in get_all_heads())
			if(head_mind.current.stat == DEAD)
				dead_heads++
			else
				alive_heads++

		if(alive_heads >= dead_heads)
			dat += "<span class='green'>The heads of staff were overthrown! The revolutionaries win! It's a clear victory!</span>"
			feedback_add_details("[ID]_success","SUCCESS")
			SSStatistics.score.roleswon++
		else
			dat += "<span class='orange'>The heads of staff were overthrown, but many heads died. The revolutionaries win, but lose support.</span>"
			feedback_add_details("[ID]_success","HALF")

	else
		dat += "<span class='red'>The heads of staff managed to stop the revolution!</span>"
		feedback_add_details("[ID]_success","FAIL")
	return dat

/datum/faction/revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		log_debug("Adding head kill/capture/convert objective for [M.mind.name]")

		var/datum/objective/target/rp_rev/rev_obj = AppendObjective(/datum/objective/target/rp_rev, TRUE)
		if(rev_obj)
			rev_obj.target = M.mind
			rev_obj.explanation_text = "Capture, convert or exile from station [M.mind.name], the [M.mind.assigned_role]. Assassinate if you have no choice."
			AnnounceObjectives()

/datum/faction/revolution/process()
	// only perform rev checks once in a while
	if(tried_to_add_revheads < world.time)
		tried_to_add_revheads = world.time + 5 SECONDS
		var/active_revs = 0
		for(var/datum/role/rev_leader/R in members)
			if(R.antag.current?.client?.inactivity <= 20 MINUTES) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_debug("There are zero active heads of revolution, trying to add some..")
			var/added_heads = FALSE
			for(var/mob/living/carbon/human/H as anything in human_list)
				if(H.stat != DEAD && H.mind && H.client?.inactivity <= 20 MINUTES && isrev(H))
					var/datum/role/R = H.mind.GetRole(REV)
					R.Drop(H.mind)
					R = HandleNewMind(H.mind)
					R.OnPostSetup(TRUE)
					added_heads = TRUE
					break

			if(added_heads)
				log_admin("Managed to add new heads of revolution.")
				message_admins("Managed to add new heads of revolution.")
			else
				log_admin("Unable to add new heads of revolution.")
				message_admins("Unable to add new heads of revolution.")
				tried_to_add_revheads = world.time + 10 MINUTES

	if(last_command_report == 0 && world.time >= 10 MINUTES)
		command_report("We are regrettably announcing that your performance has been disappointing, and we are thus forced to cut down on financial support to your station. To achieve this, the pay of all personnal, except the Heads of Staff, has been halved.")
		last_command_report = 1
		var/list/excluded_rank = list("AI", "Cyborg", "Clown Police", "Internal Affairs Agent")	+ command_positions + security_positions
		for(var/datum/job/J in SSjob.occupations)
			if(J.title in excluded_rank)
				continue
			J.salary_ratio = 0.5	//halve the salary of all professions except leading
		var/list/crew = my_subordinate_staff("Admin")
		for(var/person in crew)
			if(person["rank"] in excluded_rank)
				continue

			var/datum/money_account/account = get_account(person["account"])
			if(!account)
				continue

			account.change_salary(null, "CentComm", "CentComm", "Admin", force_rate = -50)	//halve the salary of all staff except heads

	else if(last_command_report == 1 && world.time >= 30 MINUTES)
		command_report("Statistics hint that a high amount of leisure time, and associated activities, are responsible for the poor performance of many of our stations. You are to bolt and close down any leisure facilities, such as the holodeck, the theatre and the bar. Food can be distributed through vendors and the kitchen.")
		last_command_report = 2
	else if(last_command_report == 2 && world.time >= 45 MINUTES)
		command_report("We began to suspect that the heads of staff might be disloyal to Nanotrasen. We ask you and other heads to implant the loyalty implant, if you have not already implanted it in yourself. Heads who do not want to implant themselves should be arrested for disobeying the orders of the Central Command until the end of the shift.")
		last_command_report = 3
	else if(last_command_report == 3 && world.time >= 60 MINUTES)
		command_report("It is reported that merely closing down leisure facilities has not been successful. You and your Heads of Staff are to ensure that all crew are working hard, and not wasting time or energy. Any crew caught off duty without leave from their Head of Staff are to be warned, and on repeated offence, to be brigged until the next transfer shuttle arrives, which will take them to facilities where they can be of more use.")
		last_command_report = 4

/datum/faction/revolution/proc/command_report(message)
	for (var/obj/machinery/computer/communications/comm in communications_list)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "Cent. Com. Announcement"
			intercept.info = message
			intercept.update_icon()

			comm.messagetitle.Add("Cent. Com. Announcement")
			comm.messagetext.Add(message)

	announcement_ping.play()

/datum/faction/revolution/build_scorestat()
	var/foecount = 0
	for(var/datum/role/rev_leader/lead in members)
		foecount++
		if (!lead.antag.current)
			SSStatistics.score.opkilled++
			continue
		var/turf/T = lead.antag.current.loc
		if(T)
			if (istype(T.loc, /area/station/security/brig))
				SSStatistics.score.arrested += 1
			else if (lead.antag.current.stat == DEAD)
				SSStatistics.score.opkilled++
	if(foecount == SSStatistics.score.arrested)
		SSStatistics.score.allarrested = 1
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in global.command_positions)
				if (player.stat == DEAD)
					SSStatistics.score.deadcommand++

	var/arrestpoints = SSStatistics.score.arrested * 1000
	var/killpoints = SSStatistics.score.opkilled * 500
	var/comdeadpts = SSStatistics.score.deadcommand * 500
	if (SSStatistics.score.traitorswon)
		SSStatistics.score.crewscore -= 10000
	SSStatistics.score.crewscore += arrestpoints
	SSStatistics.score.crewscore += killpoints
	SSStatistics.score.crewscore -= comdeadpts

/datum/faction/revolution/get_scorestat()
	var/dat = ""
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0

	for(var/datum/role/rev_leader/lead in members)
		if (lead.antag.current?.stat != DEAD)
			foecount++
	for(var/datum/role/rev/rev in members)
		if (rev.antag.current?.stat != DEAD)
			revcount++

	for(var/mob/living/carbon/human/player as anything in human_list)
		if(!player.mind)
			continue
		var/role = player.mind.assigned_role
		if(role in global.command_positions)
			if(player.stat != DEAD)
				comcount++
		else
			if(isrev(player))
				continue
			loycount++

	var/revpenalty = 10000
	dat += {"<B><U>REVOLUTION STATS</U></B><BR>
	<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
	<B>Number of Surviving Command Staff:</B> [comcount]<BR>
	<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
	<B>Number of Surviving Loyal Crew:</B> [loycount]<BR><BR>
	<B>Revolution Heads Arrested:</B> [SSStatistics.score.arrested] ([SSStatistics.score.arrested * 1000] Points)<BR>
	<B>Revolution Heads Slain:</B> [SSStatistics.score.opkilled] ([SSStatistics.score.opkilled * 500] Points)<BR>
	<B>Command Staff Slain:</B> [SSStatistics.score.deadcommand] (-[SSStatistics.score.deadcommand * 500] Points)<BR>
	<B>Revolution Successful:</B> [SSStatistics.score.traitorswon ? "Yes" : "No"] (-[SSStatistics.score.traitorswon * revpenalty] Points)<BR>
	<B>All Revolution Heads Arrested:</B> [SSStatistics.score.allarrested ? "Yes" : "No"] (Score tripled)<BR>"}

	return dat
