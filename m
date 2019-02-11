From: Ingo Molnar <mingo@kernel.org>
Date: Mon, 11 Feb 2019 07:11:59 +0000
Subject: Re: [PATCH] locking/rwsem: Remove arch specific rwsem files
Message-Id: <20190211071159.GA55579@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549850450-10171-1-git-send-email-longman@redhat.com>
 <a610aeb2-b1cb-0d57-8078-97d1051481f9@redhat.com>
In-Reply-To: <a610aeb2-b1cb-0d57-8078-97d1051481f9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>


* Waiman Long <longman@redhat.com> wrote:

> On 02/10/2019 09:00 PM, Waiman Long wrote:
> > As the generic rwsem-xadd code is using the appropriate acquire and
> > release versions of the atomic operations, the arch specific rwsem.h
> > files will not be that much faster than the generic code as long as the
> > atomic functions are properly implemented. So we can remove those arch
> > specific rwsem.h and stop building asm/rwsem.h to reduce maintenance
> > effort.
> >
> > Currently, only x86, alpha and ia64 have implemented architecture
> > specific fast paths. I don't have access to alpha and ia64 systems for
> > testing, but they are legacy systems that are not likely to be updated
> > to the latest kernel anyway.
> >
> > By using a rwsem microbenchmark, the total locking rates on a 4-socket
> > 56-core 112-thread x86-64 system before and after the patch were as
> > follows (mixed means equal # of read and write locks):
> >
> >                       Before Patch              After Patch
> >    # of Threads  wlock   rlock   mixed     wlock   rlock   mixed
> >    ------------  -----   -----   -----     -----   -----   -----
> >         1        27,373  29,409  28,170    28,773  30,164  29,276
> >         2         7,697  14,922   1,703     7,435  15,167   1,729
> >         4         6,987  14,285   1,490     7,181  14,438   1,330
> >         8         6,650  13,652     761     6,918  13,796     718
> >        16         6,434  15,729     713     6,554  16,030     625
> >        32         5,590  15,312     552     6,124  15,344     471
> >        64         5,980  15,478      61     5,668  15,509      58
> >
> > There were some run-to-run variations for the multi-thread tests. For
> > x86-64, using the generic C code fast path seems to be a liitle bit
> > faster than the assembly version especially for read-lock and when lock
> > contention is low.  Looking at the assembly version of the fast paths,
> > there are assembly to/from C code wrappers that save and restore all
> > the callee-clobbered registers (7 registers on x86-64). The assembly
> > generated from the generic C code doesn't need to do that. That may
> > explain the slight performance gain here.
> >
> > The generic asm rwsem.h can also be merged into kernel/locking/rwsem.h
> > as no other code other than those under kernel/locking needs to access
> > the internal rwsem macros and functions.
> >
> > Signed-off-by: Waiman Long <longman@redhat.com>
> 
> I have decided to break the rwsem patchset that I sent out on last
> Thursday into 3 parts. This patch is part 0 as it touches a number of
> arch specific files and so have the widest distribution. I would like to
> get it merged first. Part 1 will be patches 1-10 (except 4) of my
> original rwsem patchset. This part moves things around, adds more
> debugging capability and lays the ground work for the next part. Part 2
> will contains the remaining patches which are the real beef of the whole
> patchset.

Sounds good to me - I've merged this patch, will push it out after 
testing.

Thanks,

	Ingo
