-module(emock_utils).

-export([reply/2,
         reply/3,
         reply_ok/1,
         config/2]).

reply(#{request := Req} = State, StatusCode) ->
    Reply = cowboy_req:reply(StatusCode, Req),
    State#{reply => Reply}.

reply(#{request := Req} = State, ContentType, Body) ->
    Reply = cowboy_req:reply(200,
                             #{<<"content-type">> => ContentType},
                             Body,
                             Req),
    State#{reply => Reply}.

reply_ok(#{request := Req} = State) ->
    Reply = cowboy_req:reply(200, 
                             #{<<"content-type">> => <<"text/plain">>},
                             <<"">>,
                             Req),
    State#{reply => Reply}.

config(#{opts := Opts}, Key) ->
    case lists:keyfind(Key, 1, Opts) of
        false ->
            undefined;
        {_, Value} ->
            Value
    end.

