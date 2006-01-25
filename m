From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 19:01:45 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <B05667366EE6204181EABE9C1B1C0EB5097804F3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Wednesday, January 25, 2006 9:04 AM
> A few questions:
> 
> > --- linus-2.6.git/include/asm-ia64/system.h.orig	2006-01-25
01:14:07.661605464 -0800
> > +++ linus-2.6.git/include/asm-ia64/system.h	2006-01-25
01:17:36.173321660 -0800
> > @@ -255,6 +244,8 @@ extern void ia64_load_extra (struct task
> >  		__ia64_save_fpu((prev)->thread.fph);
\
> >  	}
\
> >  	__switch_to(prev, next, last);
\
> > +	if (unlikely((next)->thread.flags & IA64_THREAD_MIGRATION))
\
> > +		platform_migrate(next);
\
> >  } while (0)
> >  #else
> >  # define switch_to(prev,next,last)	__switch_to(prev, next, last)
> 
> Would it be better to add this to the IA64_HAS_EXTRA_STATE() check,
> and move the call to platform_migrate() into ia64_load_extra()?  Or
> am I failing to take something into consideration?

I suppose, I don't have strong opinion where it is being called.
Adding to ia64_load_extra(), you might need #ifdef CONFIG_SMP, of
course you can just sneak in a plain version unless people yell at
you for slowing their UP performance (I won't yell at you for UP).


> Also, yesterday when I moved the platform_migrate() call after
> __switch_task() (actually, after ia64_switch_to()) I would receive
> kernel panics during boot (the migration threads would die from an
> invalid access, swapper shortly thereafter, and finally a "soft
lockup"
> on swapper).  Was I perhaps missing something?

I can't immediately see why it won't work on sn2.  It works for me
on a Intel tiger ia64 machine.

- Ken
