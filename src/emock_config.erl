-module(emock_config).

-export([value/1,
         value/2,
         sub_value/2,
         sub_value/3,
         all/0
         ]).

value(Par) ->
    case application:get_env(emock, Par) of
        undefined ->
            undefined;
        {ok, Val} ->
            Val
    end.

value(Par, Def) ->
    case value(Par) of
        undefined ->
            Def;
        Value ->
            Value
    end.

sub_value(Par, SubPar) ->
    case application:get_env(emock, Par) of
        undefined ->
            undefined;
        {ok, Val} ->
            case lists:keyfind(SubPar, 1, Val) of
                false ->
                    undefined;
                {_, Val2} ->
                    Val2
            end
    end.

sub_value(Par, SubPar, Def) ->
    case sub_value(Par, SubPar) of
        undefined ->
            Def;
        Value ->
            Value
    end.

all() ->
    application:get_all_env(emock).

