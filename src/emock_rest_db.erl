-module(emock_rest_db).

-export([execute/2]).

execute(State, _Config) ->
    {ok, State}.

