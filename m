From: Andrew Morton <akpm@osdl.org>
Date: Thu, 18 Mar 2004 01:04:36 +0000
Subject: Re: add lowpower_idle sysctl
Message-Id: <20040317170436.430acfbe.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
In-Reply-To: <200403180031.i2I0VQF02038@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenneth Chen <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"Kenneth Chen" <kenneth.w.chen@intel.com> wrote:
>
> On ia64, we need runtime control to manage CPU power state in the idle
> loop. 

Can you expand on this?  Does this mean that the admin can select different
idle-loop algorithms?  If so, what alternative algorithms exist?

On x86 I'd like to be able to turn idle=poll on when performing oprofile
run, so the numbers come out right.  Will this let me do that?


> Logically it means a sysctl entry in /proc/sys/kernel.

Yes, but the *meanings* of the different values of that sysctl need to be
defined, and documented.  If lowpower_idleB has a totally different
meaning on different architectures then that's unfortunate but
understandable.  But we should at least enumerate the different values and
try to get different architectures to honour `42' in the same way.

> +atomic_t halt_counter;

Needs to be initialised - atomic_t's may have spinlocks inside them or
anything else.

> +extern atomic_t halt_counter;

Needs to be in a header, not in .c

>  /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
>  static int maxolduid = 65535;
> @@ -615,6 +616,14 @@
>  		.mode		= 0444,
>  		.proc_handler	= &proc_dointvec,
>  	},
> +	{
> +		.ctl_name	= KERN_LOWPOWER_IDLE,
> +		.procname	= "lowpower_idle",
> +		.data		= &halt_counter,
> +		.maxlen		= sizeof (int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec,
> +	},
>  	{ .ctl_name = 0 }
>  };

You cannot treat an int* as an atomic_t*!

Why do we want to inc and dec a user-specified tunable anyway?  I think I
don't understand what you're trying to do with this patch. 
