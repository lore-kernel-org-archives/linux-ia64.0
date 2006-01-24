From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 24 Jan 2006 00:48:50 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05825CA0@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The following patch implements this behavior on SN2 by waiting for a
> Shub register to indicate that these writes have been accepted (the
> non-SN2 case is a no-op).  This is placed in the context switch-in
> path, and only performs the wait when the newly scheduled task changes
> CPUs.

> --- a/include/asm-ia64/system.h
> +++ b/include/asm-ia64/system.h
> @@ -243,6 +243,7 @@ extern void ia64_load_extra (struct task
> 		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;			\
> 		__ia64_save_fpu((prev)->thread.fph);				\
> 	}									\
> +	platform_switch_from(next);						\
>  	__switch_to(prev, next, last);						\
>  } while (0)

On a generic kernel running on non-sn2 h/w, surely this just
added a function call to an empty function into every context
switch?

Thinking about this a bit more, wouldn't it be better to do this
work in the rebalance code that is making the decision to move
the process.  The earlier argument that this would sometimes
waste time because the process might not actually move doesn't
sound so strong ... we context switch frequently, we move processes
rarely.  Doing some work that may be wasted in the rare path sounds
better than always doing work in the common path.

-Tony
