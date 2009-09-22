From: Christoph Lameter <cl@linux-foundation.org>
Date: Tue, 22 Sep 2009 22:59:26 +0000
Subject: Re: [PATCH 2/4] ia64: allocate percpu area for cpu0 like percpu
Message-Id: <alpine.DEB.1.10.0909221856050.9410@V090114053VZO-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org> <1253605214-23210-3-git-send-email-tj@kernel.org>
In-Reply-To: <1253605214-23210-3-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <tj@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org

On Tue, 22 Sep 2009, Tejun Heo wrote:

>
> +#ifdef	CONFIG_SMP
> +  . = ALIGN(PERCPU_PAGE_SIZE);
> +  __cpu0_per_cpu = .;

__per_cpu_start?

> +  . = . + PERCPU_PAGE_SIZE;	/* cpu0 per-cpu space */
> +#endif

This is a statically sized per cpu area that is used by __get_cpu_var()
Data is access via a cpu specific memory mapping. How does this work when
the area grows beyond  PERCPU_PAGE_SIZE? As far as I can see: It seems
that __get_cpu_var would then cause a memory fault?
