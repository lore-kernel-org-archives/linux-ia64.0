From: Andrew Morton <akpm@osdl.org>
Date: Wed, 27 Jul 2005 23:13:16 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050727161316.0593d762.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>
> +#ifdef ARCH_HAS_PREFETCH_SWITCH_STACK
>  +extern void prefetch_switch_stack(struct task_struct*);
>  +#else
>  +#define prefetch_switch_stack(task)	do { } while (0)
>  +#endif

It is better to use

static inline void prefetch_switch_stack(struct task_struct *t) { }

in the second case, rather than a macro.  It provides typechecking.
