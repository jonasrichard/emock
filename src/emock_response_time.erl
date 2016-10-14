-module(emock_response_time).

-export([execute/3]).

execute(_Req, Opts, State) ->
    case lists:keyfind(response_time, 1, Opts) of
        false ->
            {ok, State};
        {_, Config} ->
            sleep(Config),
            {ok, State}
    end.

sleep(Config) ->
    case lists:keyfind(normal, 1, Config) of
        false ->
            ok;
        {normal, {_Min, Max}} ->
            timer:sleep(Max)
    end.

