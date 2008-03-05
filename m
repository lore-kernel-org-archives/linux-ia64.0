From: Russ Anderson <rja@sgi.com>
Date: Wed, 05 Mar 2008 00:23:11 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <20080305002311.GA16658@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 04, 2008 at 06:05:06PM +0100, Zoltan Menyhart wrote:
> This patch adds a lock free, yet safe way of storing MCA/INIT logs.
> You will not end up with logs mixed up from different MCAs.

A good goal.

> The MCAs/INITs are rare.

One hopes.  :-)

> There is no use wasting much permanent resources.

Sometimes a necessary evil.  Normal memory allocation routines 
cannot be called from MCA/INIT context.

> Should you see a burst of events, they are not uncorrelated.
> Only the recovered events are treated. Should you miss one,
> you'll see it later :-)
> With the others, you will not be able to store them on disk anyway.

Even if the system is going down it is still nice to try to 
go down gracefully.  Taking a system dump and logging as 
much as possible is usefull, too.

> There are IA64_MAX_MCA_INIT_BUFS log buffers for the MCA, and
> another IA64_MAX_MCA_INIT_BUFS log buffers for the INIT handler.
> 
> IA64_MAX_MCA_INIT_BUFS >= 2.
> 
> There is no per CPU log buffer.

In the case where all the CPUs are INITed, what happens?
Does this assume only one CPU at a time processes/logs records?

> The code does not assume that the rendezvous always works.

Could you explain.  Do you mean MCA/INIT rendezvous?
 

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
