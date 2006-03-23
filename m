From: Andrew Morton <akpm@osdl.org>
Date: Thu, 23 Mar 2006 02:37:36 +0000
Subject: Re: perfmon2 context: thread_struct vs. task_struct?
Message-Id: <20060322183736.4a3bb1c2.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060322233253.GB26602@frankl.hpl.hp.com>
In-Reply-To: <20060322233253.GB26602@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org

Stephane Eranian <eranian@hpl.hp.com> wrote:
>
> Hello,
> 
> The perfmon2 subsystem maintains a structure per-thread
> that contains the save-area for the performance counters
> and related software state. The save area is used on
> context-switch. There can only be one context per thread.
> The context is dynamically allocated as such it does not
> consume memory in each thread. It is dyanmically attached
> to the thread to monitor.
> 
> In the current implementation, the context (pfm_context)
> pointer is implemented in the thread_struct on the basis
> that this is somewhat related to machine state.
> 
> Historically, the perfmon subsystem only existed on IA-64
> which made the thread_struct (an arch-specific structure)
> the obvious place to put this.
> 
> Nowadays, perfmon2 supports most major architectures. It
> may make sense to move the void *pfm_context pointer from 
> the thread_struct into the task_struct. This would save
> some indirections, make it readily available to other
> archiectures when it is ported.
> 
> I admit I am not quite clear as to what goes where between
> thread_struct and task_struct.
> 
> Would it make sense  to move the pointer to the perfmon2
> context into the task_struct?

I'd say so, yes.  Especialy if the struct is the same on all architectures,
is referred to from non-arch-specific code and is absent if
CONFIG_PERFMON=n.

