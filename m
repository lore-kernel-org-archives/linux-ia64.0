From: Andrew Morton <akpm@osdl.org>
Date: Tue, 08 Feb 2005 01:35:59 +0000
Subject: Re: prezeroing V6 [2/3]: ScrubD
Message-Id: <20050207173559.68ce30e3.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	<1106828124.19262.45.camel@hades.cambridge.redhat.com>
	<20050202153256.GA19615@logos.cnet>
	<Pine.LNX.4.58.0502071127470.27951@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0502071131260.27951@schroedinger.engr.sgi.com>
	<20050207163035.7596e4dd.akpm@osdl.org>
	<Pine.LNX.4.58.0502071646170.29971@schroedinger.engr.sgi.com>
	<20050207170947.239f8696.akpm@osdl.org>
	<Pine.LNX.4.58.0502071710580.30068@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0502071710580.30068@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Mon, 7 Feb 2005, Andrew Morton wrote:
> 
> > > Look at the early posts. I plan to put that up on the web. I have some
> > > stats attached to the end of this message from an earlier post.
> >
> > But that's a patch-specific microbenchmark, isn't it?  Has this work been
> > benchmarked against real-world stuff?
> 
> No its a page fault benchmark. Dave Miller has done some kernel compiles
> and I have some benchmarks here that I never posted because they do not
> show any material change as far as I can see. I will be posting that soon
> when this is complete (also need to do the same for the atomic page fault
> ops and the prefaulting patch).

OK, thanks.  That's important work.  After all, this patch is a performance
optimisation.

> > > > Should we be managing the kernel threads with the kthread() API?
> > >
> > > What would you like to manage?
> >
> > Startup, perhaps binding the threads to their cpus too.
> 
> That is all already controllable in the same way as the swapper.

kswapd uses an old API.

> Each
> memory node is bound to a set of cpus. This may be controlled by the
> NUMA node configuration. F.e. for nodes without cpus.

kthread_bind() should be able to do this.  From a quick read it appears to
have shortcomings in this department (it expects to be bound to a single
CPU).

We should fix kthread_bind() so that it can accomodate the kscrub/kswapd
requirement.  That's one of the _reasons_ for using the provided
infrastructure rather than open-coding around it.
