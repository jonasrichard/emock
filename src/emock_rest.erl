-module(emock_rest).

-export([config/1,
         execute/2]).

config(Config) ->
    lists:map(
      fun({Path, Method, ContentType, Body}) ->
              {list_to_binary(Path),
               list_to_binary(Method),
               list_to_binary(ContentType),
               list_to_binary(Body)}
      end, Config).

execute(State, Config) ->
    #{request := Req} = State,
    {ok, do_reply(Req, Config, State)}.

do_reply(Req, Config, State) ->
    case match_urls(Req, Config) of
        undefined ->
            emock_utils:reply(State, 404);
        {ContentType, Body} ->
            emock_utils:reply(State, ContentType, Body)
    end.

match_urls(_Req, []) ->
    undefined;
match_urls(Req, [Rule | Rest]) ->
    case match_url(Req, Rule) of
        undefined ->
            match_urls(Req, Rest);
        Reply ->
            Reply
    end.

match_url(Req, {Path, Method, ContentType, Body}) ->
    case cowboy_req:method(Req) of
        Method ->
            Path2 = cowboy_req:path(Req),
            case binary:last(Path) of
                $* ->
                    %% Prefix match
                    Prefix = binary:part(Path, 0, size(Path) - 1),
                    reply_if_match(Prefix, Path2, ContentType, Body);
                _ ->
                    reply_if_match(Path, Path2, ContentType, Body)
            end;
        _ ->
            undefined
    end.

reply_if_match(Prefix, Path, ContentType, Body) ->
    case is_prefix(Prefix, Path) of
        true ->
            {ContentType, Body};
        false ->
            undefined
    end.

is_prefix(Prefix, Binary) ->
    size(Prefix) =:= binary:longest_common_prefix([Prefix, Binary]).

