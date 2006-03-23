From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 23 Mar 2006 05:41:50 +0000
Subject: Re: perfmon2 context: thread_struct vs. task_struct?
Message-Id: <20060323054150.GC26848@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060322233253.GB26602@frankl.hpl.hp.com> <20060322183736.4a3bb1c2.akpm@osdl.org>
In-Reply-To: <20060322183736.4a3bb1c2.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org

Andrew,

On Wed, Mar 22, 2006 at 06:37:36PM -0800, Andrew Morton wrote:
> > Would it make sense  to move the pointer to the perfmon2
> > context into the task_struct?
> 
> I'd say so, yes.  Especialy if the struct is the same on all architectures,
> is referred to from non-arch-specific code and is absent if
> CONFIG_PERFMON=n.
> 
Yes the structure is the same for all architectures. It looks like
task_struct already has #ifdefs in it. So I could do:

struct task_struct {
	....
#ifdef CONFIG_PERFMON
	struct pfm_context *pfm_context;
#endif
	...
};

-- 
-Stephane
