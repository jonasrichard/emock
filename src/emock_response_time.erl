-module(emock_response_time).

-export([execute/1]).

execute(State) ->
    case emock_utils:config(State, mock_rest) of
        undefined ->
            {stop, emock_utils:reply(State, 404)};
        Opts ->
            sleep(Opts),
            {ok, State}
    end.

sleep(Opts) ->
    case lists:keyfind(normal, 1, Opts) of
        false ->
            ok;
        {normal, {_Min, Max}} ->
            timer:sleep(Max)
    end.

