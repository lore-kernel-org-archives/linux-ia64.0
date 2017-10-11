From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 11 Oct 2017 19:36:28 +0000
Subject: Re: [PATCH v6 02/11] locking/rwsem: Implement a new locking scheme
Message-Id: <20171011193628.xvapnggpqci3v6cr@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
 <1507744922-15196-3-git-send-email-longman@redhat.com>
 <20171011184038.pilwo7sjf72nwaxk@hirez.programming.kicks-ass.net>
 <29f33a68-bf01-e0f0-158f-3bae3a680e80@redhat.com>
In-Reply-To: <29f33a68-bf01-e0f0-158f-3bae3a680e80@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>

On Wed, Oct 11, 2017 at 02:58:02PM -0400, Waiman Long wrote:
> On 10/11/2017 02:40 PM, Peter Zijlstra wrote:
> > So I implemented rwsem-mutex (also qrwlock based) that puts
> >
> >   (unsigned long)current | RWSEM_WRITER
> >
> > in the atomic_long_t rw_semaphore::owner field. The down-side is that
> > you can't do fetch_add based __down_read, because that would clobber the
> > pointer. The up-side is that we have a stable owner pointer (which is
> > what I needed for PI like things).
> 
> Without fetch_add for readers, it could lead to reduced performance for
> reader heavy workloads.

Yeah I know.. :-)

> Are you trying to do a PI version of rwsem? It can work when the lock is
> writer owned, but not when it is reader owned.

Not classical PI; there's one of those in -rt btw:

  https://git.kernel.org/pub/scm/linux/kernel/git/rt/linux-rt-devel.git/tree/kernel/locking/rwsem-rt.c?h=linux-4.11.y-rt

I'm implementing proxy-execution (or rather, playing with it in a few
spare moments here and there). But yes, it will only be able to boost
write owners. But in order to make that happen I need the lock state and
owner thing in the same field, like mutex.


In any case, I'll try and have a look at these patches.
