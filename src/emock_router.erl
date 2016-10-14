-module(emock_router).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
         handle_info/2,
         handle_call/3,
         handle_cast/2,
         terminate/2,
         code_change/3]).

-record(state, {
         }).

start_link() ->
    Port = emock_config:sub_value(cowboy, port, 8080),
    Listeners = emock_config:sub_value(cowboy, listeners, 10),
    Dispatch = cowboy_router:compile([
                    {'_', [{'_', emock_handler, emock_config:all()}]}
                ]),
    {ok, _Pid} = cowboy:start_clear(emock_http,
                                    Listeners,
                                    [{port, Port}],
                                    #{env => #{dispatch => Dispatch}}),
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    {ok, #state{}}.

handle_info(_Message, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

