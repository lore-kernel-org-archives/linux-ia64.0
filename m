From: Russ Anderson <rja@sgi.com>
Date: Tue, 05 Feb 2008 23:54:39 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <20080205235439.GA10413@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 05, 2008 at 04:24:33PM -0700, Bjorn Helgaas wrote:
> On Tuesday 05 February 2008 04:12:32 pm Russ Anderson wrote:
> > On Tue, Feb 05, 2008 at 01:21:00PM -0700, Bjorn Helgaas wrote:
> > 
> > > What happens if this alloc fails?
> > 
> > The updated patch will panic is alloc fails.
> 
> I don't know this code well, so I apologize for asking basic
> questions.
> 
> Is panic the only choice here?  It seems unfriendly to panic
> just because we can't successfully add a new CPU.  It'd be
> nicer to somehow make the addition fail so the new CPU is
> just not usable.

It wasn't my first choice, but ia64_mca_cpu_init() is void
so it's not as simple as returning a failing status.  That
code was written as part of early boot and if you can't 
get through boot without running out of memory you have
bigger problems.  For example, __alloc_bootmem() calls panic
if it cannot allocate memory.  There is no easy unwind path
out of that code.

Given that ia64_mca_cpu_init() does not get called in
the hot-plug path, the scenario of hot adding a cpu hitting
this panic is not possible.  If/When the hot-plug code starts
calling ia64_mca_cpu_init(), it will be an issue.  

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
