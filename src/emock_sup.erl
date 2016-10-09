-module(emock_sup).
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    {ok, {#{startegy => one_for_one,
            intensity => 5,
            period => 1000},
          [#{id => emock_router,
             start => {emock_router, start_link, []},
             restart => permanent,
             shutdown => brutal_kill,
             type => worker,
             modules => []}
          ]}
         }.
