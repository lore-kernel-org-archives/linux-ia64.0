From: Russ Anderson <rja@sgi.com>
Date: Thu, 26 Oct 2006 23:20:30 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <200610262320.k9QNKVhD22037815@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> Russ Anderson wrote:
> > I reworked that routine to look at all the valid cache target identifiers
> > and use the one with the lowest cache level.  
> > 
> > I've opened a Quad issue to get clarification from Intel as to 
> > which target identifier triggered the MCA if there are multiple
> > cache checks with valid target identifiers.  
> > 
> > This patch also leaves mca.c unchanged.  I'll treat that as a seperate
> > patch if needed.
> 
> Looks good.
> 
> But I have one more question (for intel possibly):
> - If identifiers in cache_check and bus_check are different,
>    the cache's always takes priority and the bus's will be ignored.
>    Are there any opposite case, such as a case of error log that have
>    corrected cache_checks with ignorable identifiers and an uncorrected
>    bus_check with significant identifier?

Bad data moving across the FSB does not cause an MCA (at least not
the way the hardware is configured on SGI Altix).

Usually the MCA is triggered by consuming the bad data.
"consumption" is :
  1) Loading bad data into L1 cache
  2) Loading bad data into a register file
  3) st1 or st2 to bad data
So the cache check information would be more accurate.

It's worth noting that this change does not effect the selection of
which process to kill.  It only effects which physical memory
address gets marked as bad.  

In my test case, a correctable error is injected (an ends up in the
bus check target identifier) then a memory uncorrectable is injected
and consumed, triggering the MCA.  The test program is correctly 
terminated, but the current code uses the bus check target identifier
and marks the address of the correctable error as bad.  The real bad
memory goes back on the free list, and promptly gets reused, triggering
another MCA.  The cycle repeats until the kernel happens to get
the memory.  Kernel memory error, end of ballgame.
 
> I guess if both are significant it would be separated double MCA,
> or should be reset by SAL/platform.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
