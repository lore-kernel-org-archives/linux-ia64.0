From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 13 Jul 2006 18:45:59 +0000
Subject: Re: [BUG] running strace utility can cause system to hang at sys_ptrace
Message-Id: <20060713184559.GA30462@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <44B689B9.3090902@sgi.com>
In-Reply-To: <44B689B9.3090902@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 13, 2006 at 11:24:40AM -0700, Jay Lan wrote:
> >We ran into a system hang problem at sys_ptrace.
> >
> >The system may hang if a user attempts to "strace" a pthreaded
> >application that is making frequent calls to pthread_create &
> >pthread_exit.
> >The hang is caused by a task sleeping (yield()) while holding the
> >tasklist_lock.
> >
> >Note that the problem appears to exist ONLY on IA64. IA64 has an
> >ARCH-specific implementation of sys_ptrace().

And David's patch to get rid of this ia64-special would fix this aswell:

http://marc.theaimsgroup.com/?l=linux-kernel&m1575781225495&w=2

Note that this patch would need some updates for merging these days:

 - make ptrace_attach_sync_user_rbs and architecture hook aswell, so
   that ia64 can use the generic ptrace code
 - kmalloc return value needs checking
 - adjust coding style to match the normal linux style now that
   arch/ia64/ adheres to it.

