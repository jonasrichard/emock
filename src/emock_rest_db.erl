-module(emock_rest_db).

-export([config/1,
         execute/2]).

config(Config) ->
    lager:debug("~p", [Config]),
    Config.

execute(State, _Config) ->
    #{request := Request} = State,
    Method = cowboy_req:method(Request),
    Path = cowboy_req:path(Request),
    QS = cowboy_req:qs(Request),
    Body = cowbow_req:body(Request),
    lager:debug("~p ~p ~p", [Method, Path, QS, Body]),
    {ok, State}.

handle_get(Resource) ->
    ok.

handle_get(Resource, Id) ->
    ok.

handle_post(Resource, Id, Body) ->
    ok.

