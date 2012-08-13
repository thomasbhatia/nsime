%%
%% %CopyrightBegin%
%% 
%% Copyright Saravanan Vijayakumaran 2012. All Rights Reserved.
%% 
%% %CopyrightEnd%
%%

%% Purpose : Test module for nsime_gbtrees_scheduler
%% Author : Saravanan Vijayakumaran

-module(nsime_gbtrees_scheduler_SUITE).
-author("Saravanan Vijayakumaran").

-compile(export_all).

-include("ct.hrl").
-include("../include/nsime_event.hrl").
-include_lib("eunit/include/eunit.hrl").

all() -> [
          test_creation_shutdown,
          {group, testgroup_insertion_deletion}
         ].

groups() ->
    [{
        testgroup_insertion_deletion,
        [parallel],
        [
          test_empty_initally,
          test_insert_single_event,
          test_remove_single_event
        ]
     }
    ].

init_per_suite(Config) ->
    Config.

end_per_suite(Config) ->
    Config.

init_per_group(testgroup_insertion_deletion, Config) ->
    Config.

end_per_group(testgroup_insertion_deletion, Config) ->
    Config.

test_creation_shutdown(_) ->
    nsime_gbtrees_scheduler:create(),
    Pid = erlang:whereis(nsime_gbtrees_scheduler),
        case Pid of
            undefined ->
                ct:fail("Failed to create nsime_gbtrees_scheduler process",[]);
            _ ->
                ?assert(erlang:is_pid(Pid)),
                ?assert(lists:member(nsime_gbtrees_scheduler, erlang:registered())),
                ?assertEqual(nsime_gbtrees_scheduler:stop(), killed),
                ?assertNot(lists:member(nsime_gbtrees_scheduler, erlang:registered()))
        end,
    ok.



test_empty_initally(_) ->
    nsime_gbtrees_scheduler:create(),
    ?assert(nsime_gbtrees_scheduler:is_empty()),
    nsime_gbtrees_scheduler:stop().

test_insert_single_event(_) ->
    nsime_gbtrees_scheduler:create(),
    ?assert(nsime_gbtrees_scheduler:is_empty()),
    Time = 5,
    Event = #nsime_event{
                          time = Time,
                          pid = erlang:self(),
                          module = erlang,
                          function = date,
                          eventid = make_ref()
                        },
    ?assertEqual(nsime_gbtrees_scheduler:insert(Event), ok),
    ?assertNot(nsime_gbtrees_scheduler:is_empty()),
    EventQueue = nsime_gbtrees_scheduler:get_event_queue(),
    case gb_trees:lookup(Time, EventQueue) of
        {value, [ FirstEvent | RestOfEvents]} ->
            ?assertEqual(FirstEvent, Event),
            ?assertEqual(RestOfEvents, []);
        _ ->
            ?assert(false)
    end,
    nsime_gbtrees_scheduler:stop().

test_remove_single_event(_) ->
    nsime_gbtrees_scheduler:create(),
    Time = 6,
    Event = #nsime_event{
                          time = Time,
                          pid = erlang:self(),
                          module = erlang,
                          function = date,
                          eventid = make_ref()
                        },
    nsime_gbtrees_scheduler:insert(Event),
    ?assertEqual(nsime_gbtrees_scheduler:remove_next(), Event),
    ?assert(nsime_gbtrees_scheduler:is_empty()),
    ?assertEqual(nsime_gbtrees_scheduler:remove_next(), none),
    nsime_gbtrees_scheduler:stop().

