-module(emock_rest_db).

-export([config/1,
         execute/2]).

config(Config) ->
    % Convert string values to binaries
    Prefix = config_value(Config, prefix),
    C2 = replace(Config, prefix, list_to_binary(Prefix)),
    C3 = lists:map(
           fun({resource, Resource, Opts}) ->
                   Opts1 = to_binary(Opts, path),
                   Opts2 = to_binary(Opts1, id),
                   {resource, Resource, Opts2};
              (Other) ->
                   Other
           end, C2),

    lager:debug("~p", [C3]),
    C3.

% TODO: Parse all this things into the State, since
% reading the body can affect the request. Or it can
% make impossible to implement upload?
execute(State, Config) ->
    Prefix = config_value(Config, prefix),
    #{request := Request} = State,
    Method = cowboy_req:method(Request),
    Path = cowboy_req:path(Request),
    QS = cowboy_req:qs(Request),
    lager:debug("~p ~p ~p", [Method, Path, QS]),
    case prefix_match(Path, Prefix) of
        undefined ->
            {ok, State};
        ResPath ->
            case handle(ResPath, Method, QS, Config) of
                {response, Response} ->
                    State2 = emock_utils:reply(State, <<"application/json">>, Response),
                    {stop, State2};
                _ ->
                    {ok, State}
            end
    end.

handle(ResPath, Method, QS, Config) ->
    % Match the resources in the Config
    Resources = lists:filter(
                  fun(Elem) ->
                          element(1, Elem) =:= resource
                  end, Config),
    maybe_serve_resource(Resources, ResPath, Method, QS).

maybe_serve_resource([], _, _, _) ->
    no_response;
maybe_serve_resource([{resource, Resource, Opts} | Resources], Path, Method, QS) ->
    ResPath = config_value(Opts, path),
    case prefix_match(Path, ResPath) of
        Rest when is_binary(Rest) ->
            % we found the resource
            case Method of
                <<"GET">> when Rest =:= <<>> orelse
                               Rest =:= <<"/">> ->
                    handle_get(Resource);
                <<"GET">> ->
                    << "/", Id/binary >> = Rest,
                    IntId = binary_to_integer(Id),
                    handle_get(Resource, IntId);
                _ ->
                    ok
            end;
        _ ->
            maybe_serve_resource(Resources, Path, Method, QS)
    end.

handle_get(_Resource) ->
    {response, <<"">>}.

handle_get(_Resource, _Id) ->
    ok.

handle_post(_Resource, _Id, _Body) ->
    ok.

%%% Internal functions

to_binary(Config, Key) ->
    Value = config_value(Config, Key),
    replace(Config, Key, list_to_binary(Value)).

config_value(Config, Key) ->
    {_, Value} = lists:keyfind(Key, 1, Config),
    Value.

replace(Config, Key, Value) ->
    lists:keyreplace(Key, 1, Config, {Key, Value}).

prefix_match(Binary, Prefix) ->
    S = size(Prefix),
    case binary:part(Binary, {0, S}) of
        Prefix ->
            % prefix matches, gives back the rest
            binary:part(Binary, {S, size(Binary) - S - 1});
        _ ->
            undefined
    end.
