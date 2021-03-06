%%
%%  Copyright (C) 2012 Saravanan Vijayakumaran <sarva.v@gmail.com>
%%
%%  This file is part of nsime.
%%
%%  nsime is free software: you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation, either version 3 of the License, or
%%  (at your option) any later version.
%%
%%  nsime is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with nsime.  If not, see <http://www.gnu.org/licenses/>.
%%

%% Purpose : Test module for nsime_ptp_channel
%% Author : Saravanan Vijayakumaran

-module(nsime_ptp_channel_SUITE).
-author("Saravanan Vijayakumaran").

-compile(export_all).

-include("ct.hrl").
-include("nsime_types.hrl").
-include("nsime_packet.hrl").
-include("nsime_ptp_channel_state.hrl").
-include_lib("eunit/include/eunit.hrl").

all() -> [
          {group, testgroup_all_except_transmit},
          test_transmit,
          test_cast_info_codechange
         ].

groups() ->
    [{
        testgroup_all_except_transmit,
        [
          test_creation_shutdown,
          test_creation_with_state,
          test_set_get_channel_delay,
          test_attach_netdevice
        ]
    }].
          

init_per_suite(Config) ->
    Config.

end_per_suite(Config) ->
    Config.

init_per_group(testgroup_all_except_transmit, Config) ->
    Config.

end_per_group(testgroup_all_except_transmit, Config) ->
    Config.

test_creation_shutdown(_) ->
    nsime_channel_list:start(),
    ?assert(lists:member(nsime_channel_list, erlang:registered())),
    ChannelPid = nsime_ptp_channel:create(),
    ?assert(is_pid(ChannelPid)),
    ?assertMatch({0, sec}, nsime_ptp_channel:get_channel_delay(ChannelPid)),
    ?assertEqual(nsime_ptp_channel:get_netdevice_pair(ChannelPid), {none, none}),
    ?assertEqual(nsime_ptp_channel:destroy(ChannelPid), stopped),
    ?assertEqual(nsime_channel_list:stop(), stopped),
    ok.

test_creation_with_state(_) ->
    nsime_channel_list:start(),
    ?assert(lists:member(nsime_channel_list, erlang:registered())),
    Device1 = nsime_ptp_netdevice:create(),
    Device2 = nsime_ptp_netdevice:create(),
    Delay = {3, sec},
    ChannelState = create_ptp_channel_state(Delay, Device1, Device2),
    ChannelPid1 = nsime_ptp_channel:create(ChannelState),
    ?assert(is_pid(ChannelPid1)),
    ?assertMatch(Delay, nsime_ptp_channel:get_channel_delay(ChannelPid1)),
    ?assertEqual(nsime_ptp_channel:get_netdevice_pair(ChannelPid1), {Device1, Device2}),
    ?assertEqual(nsime_ptp_channel:destroy(ChannelPid1), stopped),

    ChannelPid2 = nsime_ptp_channel:create(ChannelState),
    ?assert(is_pid(ChannelPid2)),
    ?assertMatch(Delay, nsime_ptp_channel:get_channel_delay(ChannelPid2)),
    ?assertEqual(nsime_ptp_channel:get_netdevice_pair(ChannelPid2), {Device1, Device2}),
    ?assertEqual(nsime_ptp_channel:destroy(ChannelPid2), stopped),

    ?assertEqual(nsime_channel_list:stop(), stopped),
    nsime_ptp_netdevice:destroy(Device1),
    nsime_ptp_netdevice:destroy(Device2).

test_set_get_channel_delay(_) ->
    nsime_channel_list:start(),
    ?assert(lists:member(nsime_channel_list, erlang:registered())),
    ChannelPid = nsime_ptp_channel:create(),
    ?assertMatch({0, sec}, nsime_ptp_channel:get_channel_delay(ChannelPid)),
    Delay = {3, sec},
    nsime_ptp_channel:set_channel_delay(ChannelPid, Delay),
    ?assertMatch(Delay, nsime_ptp_channel:get_channel_delay(ChannelPid)),
    nsime_ptp_channel:destroy(ChannelPid),
    ?assertEqual(nsime_channel_list:stop(), stopped).

test_attach_netdevice(_) ->
    nsime_channel_list:start(),
    ?assert(lists:member(nsime_channel_list, erlang:registered())),
    ChannelPid = nsime_ptp_channel:create(),
    Device1 = nsime_ptp_netdevice:create(),
    Device2 = nsime_ptp_netdevice:create(),
    ?assertEqual(nsime_ptp_channel:attach_netdevice(ChannelPid, Device1), ok),
    ?assertEqual(nsime_ptp_channel:get_netdevice_pair(ChannelPid), {Device1, none}),
    ?assertEqual(nsime_ptp_channel:attach_netdevice(ChannelPid, Device2), ok),
    ?assertEqual(nsime_ptp_channel:get_netdevice_pair(ChannelPid), {Device1, Device2}),
    ?assertEqual(nsime_ptp_channel:attach_netdevice(ChannelPid, Device2), none),
    ?assertEqual(nsime_ptp_channel:destroy(ChannelPid), stopped),
    ?assertEqual(nsime_ptp_netdevice:destroy(Device1), stopped),
    ?assertEqual(nsime_ptp_netdevice:destroy(Device2), stopped),
    ?assertEqual(nsime_channel_list:stop(), stopped).

test_transmit(_) ->
    nsime_simulator:start(),
    ?assert(lists:member(nsime_channel_list, erlang:registered())),
    Delay = {4, sec},
    Device1 = nsime_ptp_netdevice:create(),
    ?assert(is_pid(Device1)),
    Device2 = nsime_ptp_netdevice:create(),
    ?assert(is_pid(Device2)),
    ChannelState = create_ptp_channel_state(Delay, Device1, Device2),
    ChannelPid = nsime_ptp_channel:create(ChannelState),
    ?assert(is_pid(ChannelPid)),
    Packet = #nsime_packet{id = make_ref()},
    TxTime1 = {3, sec},
    ?assertEqual(
        nsime_ptp_channel:transmit(
            ChannelPid,
            Packet,
            Device1,
            TxTime1
        ),
        ok
    ),
    TxTime2 = {6, sec},
    ?assertEqual(
        nsime_ptp_channel:transmit(
            ChannelPid,
            Packet,
            Device2,
            TxTime2
        ),
        ok
    ),
    ?assertEqual(nsime_simulator:stop(), simulation_complete),
    ?assertEqual(nsime_ptp_netdevice:destroy(Device1), stopped),
    ?assertEqual(nsime_ptp_netdevice:destroy(Device2), stopped).

test_cast_info_codechange(_) ->
    nsime_channel_list:start(),
    ?assert(lists:member(nsime_channel_list, erlang:registered())),
    ChannelPid = nsime_ptp_channel:create(),
    ?assert(is_pid(ChannelPid)),
    gen_server:cast(ChannelPid, junk),
    ChannelPid ! junk,
    nsime_ptp_channel:code_change(junk, junk, junk),
    ?assertEqual(nsime_ptp_channel:destroy(ChannelPid), stopped),
    ?assertEqual(nsime_channel_list:stop(), stopped).

create_ptp_channel_state(Delay, Device1, Device2) ->
    #nsime_ptp_channel_state{
        delay = Delay,
        devices = {Device1, Device2}
    }.

