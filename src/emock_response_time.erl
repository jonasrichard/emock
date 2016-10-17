-module(emock_response_time).

-export([execute/2]).

execute(State, Config) ->
    sleep(Config),
    {ok, State}.

sleep(Config) ->
    case lists:keyfind(normal, 1, Config) of
        false ->
            ok;
        {normal, {_Min, Max}} ->
            timer:sleep(Max)
    end.

