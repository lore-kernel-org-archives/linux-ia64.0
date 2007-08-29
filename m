From: Roland McGrath <roland@redhat.com>
Date: Wed, 29 Aug 2007 08:01:55 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <20070829080155.0A9FD4D04CD@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Perhaps I'm misunderstanding what you mean, but isn't this what is dealt
> with in ia64_poke: if you try and update a process's user RBS via
> ptrace, it writes to the kernel RBS instead?  How do you manage to make
> the user RBS newer - are you somehow updating it via shared memory?  (In
> which case I would say don't do that ;))

This is a step on the path to getting rid of the ia64_poke kludges in
ptrace.  It has been under discussion for a long time (years now).  When
this is in place, ia64's special code for PTRACE_PEEKDATA et al will go
away and enable other desired cleanups in that code.  This also fixes the
longstanding problem that debuggers cannot reliably use /proc/pid/mem to
read all memory on ia64 (as they do on all other machines).  Because they
do not get true data for user RBS regions, debuggers now special-case ia64
and stick to using ptrace for memory access, crippling the performance of
some debugger uses (especially gdb's gcore) compared to Linux on other machines.

> IMHO copying the RBS back and forth seems like an awfully expensive
> workaround for something that would better be handled at the time that
> you actually need to write to the RBS.

Been there, done that, that's how it is now and those who did it in the
first place agreed it was a bad can of worms and this is the new plan.



Thanks,
Roland
