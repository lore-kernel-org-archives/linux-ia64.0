From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 21 Nov 2003 17:22:17 +0000
Subject: Re: speeding up thread-creation
Message-Id: <marc-linux-ia64-106943606517844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106940282522654@msgid-missing>
In-Reply-To: <marc-linux-ia64-106940282522654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

On Fri, Nov 21, 2003 at 12:19:59AM -0800, David Mosberger wrote:
> It occurred to me that at present, we're copying lots of state on a
> clone2() for absolutely no reason.  Not only that, but the large size
> of the "thread_struct" probably also causes poor cache-locality since
> the task-structure is effectively split in two, with a large unused
> gap in between.  I think it might make sense to move all the large
> thread_struct-state (IA-32 registers, pmcs[], pmds[], dbr[], ibr[],
> and fph[]) into a separate "thread_lazy" structure and then put that
> structure at a place where it doesn't hurt (perhaps above the
> thread_info structure).  If I counted right, this state accounts for
> 2KB so not copying it in copy_process() ought to speed up
> thread-creation significantly and avoid stomping needlessly on the L1
> d-cache.
> 
That looks like an good idea.

I assume you want to rely on the thread's flags to determine if it is worth
copying the thread_lazy structure during a clone. For perfmon, we may need
to have two flags: one that says we are storing information in pmds/pmcs and
one that says we need to context switch the PMU state. Today PM_VALID flag
is used to mean the latter only.

-- 
-Stephane
