-module(rest_db_SUITE).

-compile([export_all]).

all() ->
    [insert_record].

insert_record(Config) ->
    {ok, 200, _, Client} = hackney:request(<<"http://localhost:8080/api">>),
    Body = hackney:body(Client),
    Res = jsx:decode(Body),
    {<<"id">>, 1} = lists:keyfind(<<"id">>, 1, Res),
    ok.

