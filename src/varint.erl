-module(varint).
-export([encode/1,decode/1]).
-export([test_encode/0,test_decode/0,test_random/0]).

encode(Int) when is_integer(Int) ->
    case Int bsr 7 of
        0 -> <<0:1,Int:7>>;
        N -> Bin=encode(N),<<1:1,(Int band 2#1111111):7,Bin/binary>>
    end.

decode(<<0:1,V:7>>) -> V;
decode(Bin) ->
    decode(Bin,0).

decode(<<1:1,V:7,Bin/binary>>,N) ->
    (V bsl (7*N)) + decode(Bin,N+1);
decode(<<0:1,V:7>>,N) ->
    V bsl (7*N).

% ------------------------------------------------------------------
% test
% ------------------------------------------------------------------

test_encode() ->
    <<2#00000001>>=encode(1),
    <<2#01111111>>=encode(127),
    <<2#10000000,2#00000001>>=encode(128),
    <<2#11111111,2#00000001>>=encode(255),
    <<2#10101100,2#00000010>>=encode(300),
    <<2#10000000,2#10000000,2#00000001>>=encode(16384),
    ok.

test_decode() ->
    1    =decode(<<2#00000001>>),
    127  =decode(<<2#01111111>>),
    128  =decode(<<2#10000000,2#00000001>>),
    255  =decode(<<2#11111111,2#00000001>>),
    300  =decode(<<2#10101100,2#00000010>>),
    16384=decode(<<2#10000000,2#10000000,2#00000001>>),
    ok.

test_random() ->
    F = fun() -> N=rand:uniform(1 bsl 32),N=decode(encode(N)),ok end,
    [ok=F() || _ <- lists:seq(1,1000)],
    ok.
