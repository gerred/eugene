-module(term).
-export([final/1, increment/1, start/1, loop/1]).

start(Word) ->
    spawn(term, loop, [{Word, 1}]).

increment(Pid) ->
    rpc(Pid, increment).

final(Pid) ->
    rpc(Pid, final).

rpc(Pid, Request) ->
    Pid ! { self(), Request },
    receive
        {Pid, Response} ->
            Response
    end.

loop({Term, Count}) ->
    receive
        {From, increment} ->
            From ! {self(), ok},
            loop({Term, Count+1});
        {From, final} ->
            From ! {self(), {Term, Count}}
    end.
