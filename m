From: Russ Anderson <rja@sgi.com>
Date: Fri, 06 Aug 2004 21:19:08 +0000
Subject: Re: Multiple Processors on OS_MCA
Message-Id: <200408062119.i76LJ8Dm010250@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >> That wasn't intended to be a final solution ... just a temporary fix
> >> to make sure that two processors couldn't enter the kernel at the
> >> same time (which would lead to chaos in the current implementation
> >> because we only have one block of memory declared to save registers,
> >> use a stack etc.).
> >
> >Is there a plan for the next step towards the final solution?
> >
> >For example, would it make sense to have per CPU register & stack
> >save areas (etc) to handle multiple OS_MCAs concurrently?
> 
> Zoltan posted a patch to do this ... but it looked like a huge
> re-write in one big patch, and I didn't have time to look at it
> then (and still don't now).  But if you wanted to dig it up, update
> it and break it into bite-sized pieces ...

I assume you mean Zoltan Menyhart's email "Yet another INIT handler" on 2004-01-15.

http://marc.theaimsgroup.com/?l=linux-ia64&m7418478603503&w=2

It has the added benefit of per cpu INITs, too.

I'll take a closer look at it.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
