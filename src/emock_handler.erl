-module(emock_handler).

-export([init/2]).

init(Req, Opts) ->
    lager:debug("Req is ~p", [Req]),
    lager:debug("Opts is ~p", [Opts]),
    Req2 = execute_hooks(Req, Opts),
    %Req2 = cowboy_req:reply(200,
    %                        #{<<"content-type">> => <<"text/plain">>},
    %                        <<"Hello World!">>,
    %                        Req),
    {ok, Req2, Opts}.

execute_hooks(Req, Opts) ->
    case lists:keyfind(hooks, 1, Opts) of
        false ->
            default_reply;
        {_, Hooks} ->
            State = execute_hooks(Req, Opts, Hooks),
            response(Req, State)
    end.

execute_hooks(Req, Opts, Hooks) ->
    iterate_hooks(Req, Opts, Hooks, #{}).

iterate_hooks(_Req, _Opts, [], State) ->
    State;
iterate_hooks(Req, Opts, [Hook | Rest], State) ->
    case Hook:execute(Req, Opts, State) of
        {ok, State2} ->
            iterate_hooks(Req, Opts, Rest, State2);
        {stop, State2} ->
            State2
    end.

response(_Req, #{reply := Reply}) ->
    Reply;
response(Req, _) ->
    cowboy_req:reply(404, Req).

