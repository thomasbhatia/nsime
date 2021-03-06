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

%% Purpose : UDP protocol state record
%% Author : Saravanan Vijayakumaran

-define(UDP_PROTOCOL_NUMBER, 17).

-record(nsime_udp_protocol_state,
        {
          node                      :: pid(),
          ipv4_endpoints_demux      :: #nsime_ip_endpoint_demux_state{},
          ipv6_endpoints_demux      :: #nsime_ip_endpoint_demux_state{},
          sockets = []              :: [pid()],
          ipv4_down_target          :: nsime_callback(),
          ipv6_down_target          :: nsime_callback(),
          checksum_enabled = false  :: boolean()
        }).
