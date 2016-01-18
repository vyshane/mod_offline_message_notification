-module(mod_offline_message_notification).
-author("Vy-Shane Xie").
 
-behaviour(gen_mod).
 
-export([start/2, stop/1, on_offline_message/3]).
 
-include("ejabberd.hrl").
-include("jlib.hrl").
-include("logger.hrl").
 
start(_Host, _Opt) ->
    ?INFO_MSG("Starting mod_offline_message_notification", []),
    inets:start(),
    ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, on_offline_message, 50).  
 
stop (_Host) ->
    ?INFO_MSG("Stopping mod_offline_message_notification", []),
    ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, on_offline_message, 50).
 
on_offline_message(Sender, Recipient, Packet) ->
    ?INFO_MSG("Received offline message from ~p for ~p, with message ~p", [Sender, Recipient, Packet]),
    URL = os:getenv("NOTIFICATION_SERVICE_BASE_URL") ++ "/notifications/send/offlinemessage",
    Type = "application/json",
    Body = "{\"senderUserId\": \"" ++ Sender#jid.luser ++ "\", \"recipientUserId\": \"" ++ Recipient#jid.luser ++ "\", \"message\": \"" ++ Packet ++ "\"}",
    httpc:request(post, {URL, [], Type, Body}, [], []),
    ?INFO_MSG("Sent offline message notification request to ~p, with body: ~p", [URL, Body]).
