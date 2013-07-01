-module(tokenizer).
-export([test/0]).

test() -> 
    Files = lib_find:files("/home/gerred/dev/eugene", "*.txt", false),
    pmap(fun(N) -> do_tokenize(N) end, Files).

pmap(F, L) ->
    Parent = self(),
    [receive {Pid, Result} -> Result end || Pid <- [spawn(fun() -> Parent ! {self(), F(X)} end) || X <- L]].

do_tokenize(File) ->
    Bin = open_file(File),
    Tokens = string:tokens(binary_to_list(Bin), "\r\n:.!?; "),
    AccTokens = count_tokens(Tokens),
    AccTokens.

count_tokens(Tokens) ->
    lists:sort(fun (A,B) -> element(2,A) >= element(2,B) end, do_count_tokens(Tokens, [])).

do_count_tokens([], Acc) ->
    Acc;
do_count_tokens([H|Tokens], Acc) ->
    case lists:keyfind(H, 1, Acc) of
        {H, Count} ->
            do_count_tokens(Tokens, [{H, Count+1}|lists:delete({H, Count}, Acc)]);
        false ->
            do_count_tokens(Tokens, [{H, 1}|Acc])
    end.

open_file(File) ->
    {ok, Bin} = file:read_file(File),
    Bin.
