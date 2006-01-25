From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 25 Jan 2006 17:04:07 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060125104727.W16092@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 25 Jan 2006, Chen, Kenneth W wrote:

> This is the "what the heck is he talking about?" patch, on top of
> "take 4" patch:

Thank you very much.  I get it now.

What I thought you meant was flipping a bit in locations such as
migrate_task() to indicate that this task has migrated since it
last ran.  That obviously requird a scheduler hook, and where
I was running into a misunderstanding.  Thanks for clarifying it
with code.

A few questions:

> --- linus-2.6.git/include/asm-ia64/system.h.orig	2006-01-25 01:14:07.661605464 -0800
> +++ linus-2.6.git/include/asm-ia64/system.h	2006-01-25 01:17:36.173321660 -0800
> @@ -255,6 +244,8 @@ extern void ia64_load_extra (struct task
>  		__ia64_save_fpu((prev)->thread.fph);				\
>  	}									\
>  	__switch_to(prev, next, last);						\
> +	if (unlikely((next)->thread.flags & IA64_THREAD_MIGRATION))		\
> +		platform_migrate(next);						\
>  } while (0)
>  #else
>  # define switch_to(prev,next,last)	__switch_to(prev, next, last)

Would it be better to add this to the IA64_HAS_EXTRA_STATE() check,
and move the call to platform_migrate() into ia64_load_extra()?  Or
am I failing to take something into consideration?

Also, yesterday when I moved the platform_migrate() call after
__switch_task() (actually, after ia64_switch_to()) I would receive
kernel panics during boot (the migration threads would die from an
invalid access, swapper shortly thereafter, and finally a "soft lockup"
on swapper).  Was I perhaps missing something?

Thanks,
Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
