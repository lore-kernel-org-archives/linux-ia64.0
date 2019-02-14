From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 14 Feb 2019 11:12:11 +0000
Subject: Re: [PATCH v4 2/3] locking/rwsem: Remove rwsem-spinlock.c & use rwsem-xadd.c for all archs
Message-Id: <20190214111211.GL32494@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1550095217-12047-1-git-send-email-longman@redhat.com>
 <1550095217-12047-3-git-send-email-longman@redhat.com>
 <CAMuHMdVe9J4LmbLz8nHsW2JSVt8EQHTKswtc+-53pD-DBxgwSw@mail.gmail.com>
In-Reply-To: <CAMuHMdVe9J4LmbLz8nHsW2JSVt8EQHTKswtc+-53pD-DBxgwSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux <sparclinux@vger.kernel.org>, linux-riscv@lists.infradead.org, Christoph Hellwig <hch@lst.de>, Linux-Arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-c6x-dev@linux-c6x.org, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Waiman Long <longman@redhat.com>, "moderated list:H8/300 ARCHITECTURE" <uclinux-h8-devel@lists.sourceforge.jp>, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, linux-um@lists.infradead.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Feb 14, 2019 at 11:54:47AM +0100, Geert Uytterhoeven wrote:
> On Wed, Feb 13, 2019 at 11:01 PM Waiman Long <longman@redhat.com> wrote:
> > Currently, we have two different implementation of rwsem:
> >  1) CONFIG_RWSEM_GENERIC_SPINLOCK (rwsem-spinlock.c)
> >  2) CONFIG_RWSEM_XCHGADD_ALGORITHM (rwsem-xadd.c)
> >
> > As we are going to use a single generic implementation for rwsem-xadd.c
> > and no architecture-specific code will be needed, there is no point
> > in keeping two different implementations of rwsem. In most cases, the
> > performance of rwsem-spinlock.c will be worse. It also doesn't get all
> > the performance tuning and optimizations that had been implemented in
> > rwsem-xadd.c over the years.
> >
> > For simplication, we are going to remove rwsem-spinlock.c and make all
> > architectures use a single implementation of rwsem - rwsem-xadd.c.
> >
> > All references to RWSEM_GENERIC_SPINLOCK and RWSEM_XCHGADD_ALGORITHM
> > in the code are removed.
> >
> > Suggested-by: Peter Zijlstra <peterz@infradead.org>
> > Signed-off-by: Waiman Long <longman@redhat.com>
> 
> Note that this conflicts with "[PATCH 03/11] kernel/locks: consolidate
> RWSEM_GENERIC_* options"
> https://lore.kernel.org/lkml/20190213174005.28785-4-hch@lst.de/

*sigh*.. of that never was Cc'ed to locking people :/
