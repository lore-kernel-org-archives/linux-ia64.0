From: Russ Anderson <rja@sgi.com>
Date: Tue, 11 Mar 2008 21:22:21 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080311212219.GB18532@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'd much rather focus on the actual code.  
See debug information at the end.

On Tue, Mar 11, 2008 at 03:07:20PM +0100, Zoltan Menyhart wrote:
> Russ Anderson wrote:
> >...
> >>As far as the my MCA stuff is concerned, can you agree that it is
> >>safer than the original code?
> >
> >Yes.  I like your approach.  I want to make sure it works
> >on larger systems.
> 
> If it comes from a boot command line option...
> 
> >>E.g. my MCA stuff can start up with, say, 3 buffers by default,
> >>and you will be able to override it by a boot command line option.
> >
> >How about having N be the number of actual cpus?  
> 
> Let me ask again: do you expect _independent_ MCAs to happen?

Depends on what you mean by _independent_.  I have a lot of experience
with _cascading_ MCAs, where there is a root cause failure quickly
followed by other MCAs as a side effect of the initial failure all
occuring as one MCA event.  In those cases capturing all the MCA
information and sorting through to reconstruct the events is vital
to find the root cause.  Whether the MCAs are due to one root cause
or multiple causes is not clear until after the analysis.

Multiple CPUs going through MCA at the same time is not an abstract
scenario.  It is not uncomon to have many processes accessing
the same shared memory and hitting the same bad memory.  That is
why I have test cases for those scenarios.

> If the MCAs are the consequences of the same error event, then
> you can find out what they are, where they are from 2 or 3 logs.

Easier said than done in real life.

> The code actual tries to recover local MCAs only. They are:
> - TLB errors: per CPU local. As the CPUs are much more reliable
>  then the other components, e.g. the memory, having two or
>  more CPUs with corrupted TLBs at the same time is really unlikely.
> - I/O or memory read errors:
>  + One error has affected N CPUs: the first log is enough.

In the case of two processes consuming the same bad data, it
is often the second processes that calls up to OS_MCA first.
The reason is in SAL, the first CPU into MCA tries to rendezvou
the others.  The second one in (beating the rendezvou) sees
the first is doing the rendezvou so he immediately call into
linux OS_MCA.  So the second CPU shows up in OS_MCA before
the first.  There is no guarantee that the first error
in hardware wins the race to be the first in linux OS_MCA.

>  + More than one independent error at the same time: assuming
>    my estimations are more or less correct...

Another recent example of multiple CPUs going into MCA at
the same time was a hot lock on a large system with enough
contention to cause memory timeouts.  It was by looking at
the MCA records that we were able to identify the hot lock
and fix the code.
 
> I still don't see any need for many buffers.

In testing, I found one of the records getting dropped in salinfo.c
at the comment "saved record changed by mca.c since interrupt, discard it".
That code was not added by your patch, but is something that
impacts logging.

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
