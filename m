From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 31 Oct 2001 22:23:25 +0000
Subject: Re: [Linux-ia64] gcc won't inline function returning struct?
Message-Id: <marc-linux-ia64-105590698805424@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The IA-64 ABI says that structures of floats are passed/returned decomposed
into floating point registers.  They ABI calls them homogeneous floating-point
aggregates, or HFA for short.  This also applies to complex types.  Thus your
structure
	typedef struct {
        	float re, im;
	} complex;
is handled by putting RE in one FP register, and IM in the next.  This is
not normal practice, since the structure is 8 bytes, but ends up using 16
bytes worth of register (ignoring long double to simplify the discussion).
This requires special code to decompose/compose HFA arguments and return
values on IA-64 when loading/storing them.  IA-32 does not use this convention,
and thus does not need special code for HFAs.

Because of the old design of the C front end, this special code is problematic.
The C front end generates low level code first, including code to compose/
decompose HFAs, and then tries to do function inlining.  When we inline a
function, we have to optimize away the code that composes/decomposes HFAs,
and this is so difficult that in practice it isn't worthwhile to try.  Thus
we can not inline a function that uses an HFA argument or return value.

The C++ front uses a more recent design that inlines first, and then generates
low level code including the HFA compose/decompose code.  If you compile your
example as C++ code, it will work.

Work is underway to rewrite the C front end to make it work more like the C++
front end, or perhaps even just use the C++ front end for C.  When this work
gets far enough, inlining of HFA functions will work in C.  I just tried your
example with the current FSF development sources, and it did work, so I think
this is fixed as of Alexandre Oliva's 2001-10-05 gcc changes to the C front
end.  I don't know how well it is working at the moment though.  However,
I would expect it to be working fine by the time gcc 3.1 comes out in spring of
2002.

Another consideration here is that the IL (Intermediate Language) used by
gcc has no support for representing decomposed structures.  If we did,
then we could get much better optimization of structures by separately
optimizing every structure field as if it was a scalar.  But we don't,
so the only way we can handle decomposed structures as arguments is to
decompose them before the call, and then recompose them in the function
prologue.  This is pretty inefficient, but it does work.  Fixing this will
be a lot of work, and it will likely be a while before anyone tries.

Jim

