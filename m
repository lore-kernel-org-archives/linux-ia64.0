From: Robin Holt <holt@sgi.com>
Date: Wed, 16 Jun 2004 19:36:22 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040616193622.GC17425@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 06:43:47PM +0100, Christoph Hellwig wrote:
> On Wed, Jun 16, 2004 at 12:40:53PM -0500, Robin Holt wrote:
> > > > Index: linux/kernel/exit.c
> > > > =================================> > > > --- linux.orig/kernel/exit.c	Thu Jun 10 15:04:09 2004
> > > > +++ linux/kernel/exit.c	Thu Jun 10 16:31:55 2004
> > > > @@ -1184,6 +1184,7 @@ end_wait4:
> > > >  	remove_wait_queue(&current->wait_chldexit,&wait);
> > > >  	return retval;
> > > >  }
> > > > +EXPORT_SYMBOL(sys_wait4);
> > > 
> > > No way.  Calling syscalls from kernelspace is always a bad idea.  (And this
> > > is not linux-ia64 material anyway)
> > 
> > How should a parent thread be reaping children?
> > 
> > > 
> > > > Index: linux/kernel/sched.c
> > > > =================================> > > > --- linux.orig/kernel/sched.c	Thu Jun 10 16:30:39 2004
> > > > +++ linux/kernel/sched.c	Thu Jun 10 16:31:55 2004
> > > > @@ -2814,6 +2814,7 @@ asmlinkage long sys_sched_setscheduler(p
> > > >  {
> > > >  	return setscheduler(pid, policy, param);
> > > >  }
> > > > +EXPORT_SYMBOL(sys_sched_setscheduler);
> > > 
> > > Again, don't mess with scheduler paramters from your modules.
> > 
> > How should a kernel thread raise itself to real-time priority?
> 
> Answer to both:  it shouldn't

To the second, we found that contention would result in very high
latency without raising the priority to real-time levels.  What is
the proper way to handle having a user thread at the same priority
as a kernel thread causing this holdoff?
