From: Mario Smarduch <cms063@email.mot.com>
Date: Mon, 11 Nov 2002 16:29:29 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805382@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rusty Russell wrote:

> In message <1036777105.13021.13.camel@ixodes.goop.org> you write:
> > On Fri, 2002-11-08 at 09:25, Linus Torvalds wrote:
> > > There's another reason for not doing it that way: allowing readers to keep
> > > interrupts on even in the presense of interrupt uses of readers.
> > >
> > > If you do the "pending writes stop readers" approach, you get
> > >
> > >             cpu1                    cpu2
> > >
> > >             read_lock() - get
> > >
> > >                                     write_lock_irq() - pending
> > >
> > >             irq happens
> > >              - read_lock() - deadlock
> > >
> > > and that means that you need to make readers protect against interrupts
> > > even if the interrupts only read themselves.
> >
> > Even without interrupts that would be a bug.  It isn't ever safe to
> > attempt to retake a read lock if you already hold it, because you may
> > deadlock with a pending writer.  Fair multi-reader locks aren't
> > recursive locks.
>
> That's the point.  This is explicitly guaranteed with the current
> locks, and you are allowed to recurse on them.  The netfilter code
> explicitly uses this to retake the net brlock, since it gets called
> from different paths.
>
> Implement "read_lock_yield" or "wrlock_t" but don't break existing
> semantics until 2.7 *please*!
>
> Rusty.
> --
>   Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

From what I understand this is a huge security risk - any mischevious user
can hang the system. Practically speaking its a hard sell to tell any customer
that in 2.7 the problem will be fixed and hope that it doesnt happen before
then.  Is there any way to prevent the user (non-root) from exploiting this
weakness? In order for this to happen do all the CPUs have to run at
100%? I know that on some commercial Unix systems there are ways
to cap the CPU utilization by user/group ids are there such features/patches
available
on Linux?

- Mario.


