From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Sun, 09 Jan 2005 17:06:37 +0000
Subject: Re: [PATCH] ia64: reset console_loglevel so INIT output always goes to console
Message-Id: <200501091706.j09H6biC046599@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105140871.25267.50.camel@eeyore>
In-Reply-To: <1105140871.25267.50.camel@eeyore>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> 
> We are slowly but steadily moving to recovery from some MCA events.  If
> one of the cpus is spinning disabled when an MCA occurs then the
> disabled cpu will get a slave INIT event as part of the MCA rendezvous.
> If the MCA is recoverable then the slave INIT event will also be
> recoverable and will eventually return to user space.
> 
> That change is still some way off, but bear it in mind when changing
> the existing code.

Good points, Keith.

There are a number of changes that will be needed now that MCAs and INITs
are becoming recoverable.  A disabled CPU should not receive an INIT
as part of MCA rendezvous.  Some of the changes will require changes
in the MCA and SAL specs.

For example, having SAL rendezvous all the CPUs before calling OS_MCA 
may have been reasonable when linux lacked the ability to recover from 
an MCA.  But now that is changing, the descision to rendezvous CPUs
should get made later, in linux, if it cannot recover from the MCA.
Does it really make sense to rendezvous 512 CPUs just because one
CPU happened to hit a memory uncorrectable in a user application
(and recovers by killing the appication and discarding the page)?

Does it still make sense to have only one call into OS_MCA at
a time?  Or is it more reasonable to support multiple OS_MCAs
and let the linux MCA code coordinate processing of the OS_MCA,
when needed?  As the code progresses, it should be reasonable move 
more of the decision & coordination code further into the
recovery code (or at least not prevent that from happening) so
that, for example, multiple independent MCAs can be recovered
in parallel.

As I said, this will require changes in the MCA & SAL specs.
Some are simply clearing up ambiguities in the specs, as Keith found
in MCA logging of recovered errors.  Some will be more fundamental 
changes to support better recovery.  The code has reached the point 
where we need to start making enhancements to those specs.

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
