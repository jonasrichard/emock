-module(emock_router).

-export([start_link/0,
         config/1]).

start_link() ->
    Port = emock_config:sub_value(cowboy, port, 8080),
    Listeners = emock_config:sub_value(cowboy, listeners, 10),
    Hooks = emock_config:value(hooks),
    configure_hooks(Hooks),
    Dispatch = cowboy_router:compile([
                    {'_', [{'_', emock_handler, #{hooks => Hooks}}]}
                ]),
    {ok, _Pid} = cowboy:start_clear(emock_http,
                                    Listeners,
                                    [{port, Port}],
                                    #{env => #{dispatch => Dispatch}}).

config(Module) ->
    case ets:lookup(emock_config, Module) of
        [] ->
            undefined;
        [{_, Config}] ->
            Config
    end.

%%%
%%% Internal functions
%%%

configure_hooks(Hooks) ->
    ets:new(emock_config, [set, named_table, {read_concurrency, true}]),

    lists:foreach(fun configure_hook/1, Hooks).

configure_hook(Hook) ->
    Config = emock_config:value(Hook),
    NewConfig = case erlang:function_exported(Hook, config, 1) of
                    true ->
                        Hook:config(Config);
                    false ->
                        Config
                end,
    ets:insert(emock_config, {Hook, NewConfig}).

