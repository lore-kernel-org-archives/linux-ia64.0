From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 23 Mar 2001 20:28:06 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005347@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Fair enough.  But I hope are not discounting the usefulness of a
>short-circuit return just because gcc happens not to generate such
>code at the moment.

>	mov rp = common_exit_path_code
>	br.call b6 = handler

I'm trying not to discount it, but I do need to understand it, and how it
effects other features of the compiler.

If your only interest in unwind info is being able to unwind another frame,
then this optimization works fine.  All you need to do is make sure the
frame state is the same at the branch target.  This is pretty easy to do,
and you are already doing it.

However, there are conflicts with other compiler features.  Someone from SGI
alluded to this, but did not give specific examples.

Consider debugging.  If we are in the debugger in the callee, and then go up
one frame and try to look at local variables, then this will fail if the call
and the branch target are in different lexical blocks.  This also makes it
difficult to impossible to determine where the call came from when inside the
callee.  So this makes debugging more difficult, however, debugging optimized
code has enough problems already that this isn't a good enough reason to avoid
the optimization.

Consider C++ EH.  If the call and the branch target are in different
exception regions, and the callee throws an exception, then we will end up
calling the wrong exception handler.  This does not prevent us from performing
the optimization if there are no exception regions, or if the call and the
branch target are in the same exception region.  The design of the EH system
may have an effect on whether this example is valid.  I know it is valid for
the table based EH system that gcc currently uses.  I don't know enough about
the new C++ ABI unwind API to know if it is valid there.

Therefore, it makes sense to allow the optimization, and adjust the unwinder
so that it can handle this case.

>the frame state for cover (in all likelihood).  Note that according to
>Cary, the above example would be illegal because the frame state
>changes between the point of br.call and the address that "rp" points
>to.  But it shows that even without Cary's rule you'd could still get

I don't know who Cary is, or why we have to follow his rules.  All I know about
him is his email address.  However, he does seem to be relatively knowledgable
about unwind issues, so I'm willing to consider his opinions.

>Also, I'd like to point out that if X is a valid bundle address, then
>X-1 is NOT a valid instruction address as it contains 0xf in the least
>significant four bits.  I suspect that if you pass such an address to
>an unwind library, you end up relying on implementation specific
>behavior.

Subtracting one from an instruction address by itself is obviously not a valid
thing to do, but we need to keep in mind the context here.

When unwinding, we are doing a table lookup.  The address space is split into
a bunch of separate unwind regions, each one stopping where the next one
starts.  This leaves us vulnerable to boundary crossing problems.  If a call
occurs in the last bundle of an unwind region, then the return address points
to the next unwind region.  In gcc, we fix this problem by subtracting one
from the return address before doing the table lookup.  This ensures that
we are always in the same unwind region as the call instruction.  This solves
the problem with noreturn calls at the end of functions.  It also solves
other potential problems.  For the IA-64 unwind ABI, you are trying to solve
this problem by forbidding unwind regions from ending immediately after a call.
This is done partly via Cary's rule, and partly by asking for breaks/nops
after a noreturn call at the end of a function.  This also incidentally makes
the kernel optimization work, since the return address subtraction is no longer
needed.  In gcc, we still need this for the DWARF2 unwinder though, unless
we are going to apply these same rules for all architectures.

Similarly, when doing C++ exception handling, we are doing a table lookup.
The address space in split into a bunch of separate exception regions, and
there is a boundary-crossing problem if a call is the last instruction of an
exception region.  We also fix this by subtracting one from the return address
before the table lookup.  In fact, it is the exact same subtraction we do
above, we only have to do it once.  I don't know enough about the new C++ ABI
unwind API to know if this problem is still present.  There is the problem
that gcc doesn't have the new unwind API as yet.  We are still using our
exception table approach, and hence we still need the subtract one in the
IA-64 unwinder to make C++ EH.  If the new unwind API does not have this
boundary problem, then the subtraction can go away when we switch to it.

Jim

