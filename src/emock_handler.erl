-module(emock_handler).

-export([init/2]).

init(Req, Opts) ->
    lager:debug("Req is ~p", [Req]),
    lager:debug("Opts is ~p", [Opts]),
    Req2 = execute_hooks(Req, Opts),
    {ok, Req2, Opts}.

execute_hooks(Req, #{hooks := Hooks}) ->
    State = iterate_hooks(Hooks, #{request => Req}),
    response(Req, State).

iterate_hooks([], State) ->
    State;
iterate_hooks([Hook | Rest], State) ->
    Config = emock_router:config(Hook),
    case Hook:execute(State, Config) of
        {ok, State2} ->
            iterate_hooks(Rest, State2);
        {stop, State2} ->
            State2
    end.

response(_Req, #{reply := Reply}) ->
    Reply;
response(Req, _) ->
    cowboy_req:reply(404, Req).

