From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 22 Mar 2006 23:32:53 +0000
Subject: perfmon2 context: thread_struct vs. task_struct?
Message-Id: <20060322233253.GB26602@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org

Hello,

The perfmon2 subsystem maintains a structure per-thread
that contains the save-area for the performance counters
and related software state. The save area is used on
context-switch. There can only be one context per thread.
The context is dynamically allocated as such it does not
consume memory in each thread. It is dyanmically attached
to the thread to monitor.

In the current implementation, the context (pfm_context)
pointer is implemented in the thread_struct on the basis
that this is somewhat related to machine state.

Historically, the perfmon subsystem only existed on IA-64
which made the thread_struct (an arch-specific structure)
the obvious place to put this.

Nowadays, perfmon2 supports most major architectures. It
may make sense to move the void *pfm_context pointer from 
the thread_struct into the task_struct. This would save
some indirections, make it readily available to other
archiectures when it is ported.

I admit I am not quite clear as to what goes where between
thread_struct and task_struct.

Would it make sense  to move the pointer to the perfmon2
context into the task_struct?

Thanks.

-- 
-Stephane
