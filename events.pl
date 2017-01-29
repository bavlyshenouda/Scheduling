
event_in_course(csen403, labquiz1, assignment).
event_in_course(csen403, labquiz2, assignment).
event_in_course(csen403, project1, evaluation).
event_in_course(csen403, project2, evaluation).
event_in_course(csen403, quiz1, quiz).
event_in_course(csen403, quiz2, quiz).
event_in_course(csen403, quiz3, quiz).

event_in_course(csen401, quiz1, quiz).
event_in_course(csen401, quiz2, quiz).
event_in_course(csen401, quiz3, quiz).
event_in_course(csen401, milestone1, evaluation).
event_in_course(csen401, milestone2, evaluation).
event_in_course(csen401, milestone3, evaluation).

event_in_course(csen402, quiz1, quiz).
event_in_course(csen402, quiz2, quiz).
event_in_course(csen402, quiz3, quiz).

event_in_course(math401, quiz1, quiz).
event_in_course(math401, quiz2, quiz).
event_in_course(math401, quiz3, quiz).

event_in_course(elct401, quiz1, quiz).
event_in_course(elct401, quiz2, quiz).
event_in_course(elct401, quiz3, quiz).
event_in_course(elct401, assignment1, assignment).
event_in_course(elct401, assignment2, assignment).

event_in_course(csen601, quiz1, quiz).
event_in_course(csen601, quiz2, quiz).
event_in_course(csen601, quiz3, quiz).
event_in_course(csen601, project, evaluation).
event_in_course(csen603, quiz1, quiz).
event_in_course(csen603, quiz2, quiz).
event_in_course(csen603, quiz3, quiz).

event_in_course(csen602, quiz1, quiz).
event_in_course(csen602, quiz2, quiz).
event_in_course(csen602, quiz3, quiz).

event_in_course(csen604, quiz1, quiz).
event_in_course(csen604, quiz2, quiz).
event_in_course(csen604, quiz3, quiz).
event_in_course(csen604, project1, evaluation).
event_in_course(csen604, project2, evaluation).


holiday(3,monday).
holiday(5,tuesday).
holiday(10,sunday).


studying(csen403, group4MET).
studying(csen401, group4MET).
studying(csen402, group4MET).

studying(csen601, group6MET).
studying(csen602, group6MET).
studying(csen603, group6MET).
studying(csen604, group6MET).

should_precede(csen403,project1,project2).
should_precede(csen403,quiz1,quiz2).
should_precede(csen403,quiz2,quiz3).

quizslot(group4MET, tuesday, 1).
%quizslot(group4MET, tuesday, 2).

quizslot(group4MET, thursday, 1).
quizslot(group6MET, saturday, 5).

%Code name day slot group weekNumber

getFromList([H|_],H).

getFromList([_|T],H):- 
                    getFromList(T,H). 

available_timings(G,L):-   
                         findall((X,Y),quizslot(G,X,Y),L).
						 
availableSlots(0,_,[]).
availableSlots(Week,Time,L):-
                               Week\=0,
							   assignSlot(Week,Time,L1),
							   W1 is Week-1,
                               availableSlots(W1,Time,L2),
                               append(L2,L1,L).							   
                          								
assignSlot(_,[],[]).
assignSlot(Week,[H|T],L):-
                          H=(Day,Slot),
                          X=(Day,Slot,Week),
                          assignSlot(Week,T,L1),
                          L=[X|L1].	

removeHoliday(X,[],X).
removeHoliday(Slots,Holiday,L):-						  
						          Holiday=[H|T],
                                  H=(Week,Day),
                                  X=(Day,_,Week),
                                  subtract(Slots,[X],L1),
                                  removeHoliday(L1,T,L).

slot(Group,Week,Slots):-
                              available_timings(Group,Time),
							  availableSlots(Week,Time,L),
                              findall((X,Y),holiday(X,Y),L1),
                              removeHoliday(L,L1,Slots).							  
             							  
group_events(G,Events):-
                           findall(X,studying(X,G),L),
						   remDub(L,L1),
						   getEvents(L1,Events).
						   
remDub([],[]).
remDub([H|T], [H|T1]) :- subtract(T,[H],T2), remDub(T2, T1).
						   
getEvents([],[]).
getEvents(L,L1):-   
                        L=[H|T],
						findall(X,event_in_course(H,X,_),L2),
						addCode(H,L2,L4),
						getEvents(T,L3),
						append(L4,L3,L1).
						
addCode(_,[],[]).
						
addCode(X,[H|T],[(X,H)|T1]):-
                                addCode(X,T,T1).
								
precede(_,[_]).
precede(G,Schedule):-
	              findLastEvent(Schedule,(CourseCode,EventName,_,_,G,_)),
	              not(should_precede(CourseCode,_,EventName)).
								
precede(G,Schedule):-
	              findLastEvent(Schedule,(CourseCode,EventName,_,_,G,_)),
	              should_precede(CourseCode,Pre,EventName),
	              member((CourseCode,Pre,_,_,_,_),Schedule).

findLastEvent([Event],Event).
findLastEvent([_|T],Event):- findLastEvent(T,Event).

no_same_day_quiz(G,[(CourseCode1,Event1,_,_,G,_),(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]):-
	   not(event_in_course(CourseCode1, Event1, quiz)),
	   no_same_day_quiz(G,[(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]).

no_same_day_quiz(G,[(CourseCode1,Event1,Day1,_,G,Week_Number1),(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]):-
	event_in_course(CourseCode1, Event1, quiz),
	event_in_course(CourseCode2, Event2, quiz),
	Week_Number1=Week_Number2,
	Day1\=Day2,
	no_same_day_quiz(G,[(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]).

no_same_day_quiz(G,[(_,_,_,_,G,Week_Number1),(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]):-
	Week_Number1\=Week_Number2,
	no_same_day_quiz(G,[(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]).

no_same_day_quiz(_,[_]).



no_same_day_assignment(G,[(CourseCode1,Event1,_,_,G,_),(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]):-
	not(event_in_course(CourseCode1, Event1, assignment)),
	no_same_day_assignment(G,[(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]).

no_same_day_assignment(G,[(CourseCode1,Event1,Day1,_,G,Week_Number1),(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]):-
	event_in_course(CourseCode1, Event1, assignment),
	event_in_course(CourseCode2, Event2, assignment),
	Week_Number1=Week_Number2,
	Day1\=Day2,
	no_same_day_assignment(G,[(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]).
no_same_day_assignment(G,[(_,_,_,_,G,Week_Number1),(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]):-
	Week_Number1\=Week_Number2,
	no_same_day_assignment(G,[(CourseCode2,Event2,Day2,_,G,Week_Number2)|L]).
no_same_day_assignment(_,[_]).


no_consec_quiz(_,[_]).

no_consec_quiz(_,Schedule):-
	findLastEvent(Schedule,(CourseCode,EventName,_,_,_,_)),
        not(event_in_course(CourseCode,EventName,quiz)).
	
no_consec_quiz(_,Schedule):-
	findLastEvent(Schedule,(CourseCode,EventName,_,_,_,_)),
	not(should_precede(CourseCode,_,EventName)).

no_consec_quiz(G,Schedule):-
	findLastEvent(Schedule,(CourseCode,EventName,Day,Slot,G,Week_Number)),
        event_in_course(CourseCode,EventName,quiz),
	should_precede(CourseCode,Pre,EventName),
	findAndCompare(Pre,Schedule,(CourseCode,EventName,Day,Slot,G,Week_Number)).



findAndCompare(Quiz2,[event(CourseCode,Quiz2,_,_,G,Week_Number1)|_],event(CourseCode,_,_,_,G,Week_Number)):-
	W is Week_Number1+1,
	Week_Number>=W.
findAndCompare(Quiz2,[event(CourseCode1,EventName1,_,_,G,_)|T],event(CourseCode,EventName,Day,Slot,G,Week_Number)):-
	CourseCode1\=CourseCode,
	EventName1\=Quiz2,
	findAndCompare(Quiz2,T,event(CourseCode,EventName,Day,Slot,G,Week_Number)).

generate([],_,_,_,[]).
generate(L,[H|T],Group,OldSchedule,Schedule):- 
							 getFromList(L,X),
							 X=(Code,Name),
							 H=(Day,Slot,Week),
							 Event=(Code,Name,Day,Slot,Group,Week),
							 subtract(L,[X],L1),
                             append(OldSchedule,[Event],NewSchedule),
                             precede(Group,NewSchedule),
							 no_consec_quiz(Group,NewSchedule),
                             no_same_day_assignment(Group,NewSchedule),
							 no_same_day_quiz(Group,NewSchedule),
							 generate(L1,T,Group,NewSchedule,Schedule1),
							 append([Event],Schedule1,Schedule).
							 
%generate(L,[_|T],Group,OldSchedule,Schedule):- 
                                          %generate(L,T,Group,OldSchedule,Schedule).								

schedule(Week,Schedule):-  
                                 G=group4MET,
								 group_events(G,Events),
                                 slot(G,Week,Slots),
                                 generate(Events,Slots,G,[],Schedule).								 
								  
									
									

