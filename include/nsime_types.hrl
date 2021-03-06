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

%% Purpose : Nsime type definitions
%% Author : Saravanan Vijayakumaran

-type nsime_time_unit() :: sec | milli_sec | micro_sec | nano_sec.

-type nsime_time() :: {number(), nsime_time_unit()}.

-type nsime_data_rate_unit() :: bits_per_sec
                              | bytes_per_sec
                              | kilo_bits_per_sec
                              | kilo_bytes_per_sec
                              | mega_bits_per_sec
                              | mega_bytes_per_sec
                              | giga_bits_per_sec
                              | giga_bytes_per_sec.

-type nsime_data_rate() :: {number(), nsime_data_rate_unit()}.

-type nsime_tx_device_state() :: ready | busy.

-type nsime_callback() :: {module(), fun(), list()} | {none, none, none}.

-type nsime_address_prefix_atom() :: 255 | 254 | 252 | 248 |
                                     240 | 224 | 192 | 128.

-type nsime_ipv4_mask() :: {nsime_address_prefix_atom(), 0, 0, 0}
                         | {255, nsime_address_prefix_atom(), 0, 0}
                         | {255, 255, nsime_address_prefix_atom(), 0}
                         | {255, 255, 255, nsime_address_prefix_atom()}.

-type nsime_netdevice_packet_type() :: packet_host | packet_broadcast |
                                       packet_multicast | packet_otherhost.

-type nsime_socket_type() :: sock_stream | sock_seqpacket |
                             sock_dgram | sock_raw.

-type nsime_socket_error() :: error_noterror
                            | error_isconn
                            | error_notconn
                            | error_msgsize
                            | error_again
                            | error_shutdown
                            | error_opnotsupp
                            | error_afnosupport
                            | error_inval
                            | error_badf
                            | error_noroutetohost
                            | error_nodev
                            | error_addrnotavail
                            | error_addrinuse.

-type nsime_socket_address() :: {inet:ip_address(), inet:port_number()}.

-type nsime_layer4_receive_status() :: rx_ok
                                     | rx_csum_failed
                                     | rx_endpoint_closed
                                     | rx_endpoint_unreach.

-type nsime_ipv4_drop_reason() :: drop_ttl_expired
                                | drop_no_route
                                | drop_bad_checksum
                                | drop_interface_down
                                | drop_route_error
                                | drop_fragment_timeout.
