From: Andrew Morton <akpm@osdl.org>
Date: Tue, 10 May 2005 23:10:40 +0000
Subject: Re: [patch] add arch_ptrace_stop() hook and use it on ia64
Message-Id: <20050510161040.28b4a019.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <17025.6719.837031.411067@napali.hpl.hp.com>
In-Reply-To: <17025.6719.837031.411067@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: davidm@napali.hpl.hp.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, roland@redhat.com

David Mosberger <davidm@napali.hpl.hp.com> wrote:
>
> The hook lets architectures do their own thing when a task stops for
> ptrace.  In the case of ia64, we'd like to use this to update the
> user's virtual memory with the portion of the register-backing store
> that ended up on the kernel-stack.
> 
> Note that the patch changes ptrace_stop() to release the
> sighand->siglock before setting the task to TASK_TRACED state.  This
> is needed such that arch_ptrace_stop() can run without holding
> sighand->siglock (arch_ptrace_stop() may access user-memory and hence
> indirectly modify the task's run state and hence it is not possible to
> establish the TASK_TRACED state before running the hook).

Are we really sure about this?  A quick peek at ptrace_check_attach() and
ptrace_untrace() (for example) indicates that we are using ->siglock to
synchronise access to the task state.

It's hard to see how swapping the assignment and the unlock in there could
break anything, but it does need to be gone through with a toothcomb
looking for synchronization issues as well as for missing memory barriers
(ptrace_check_attach doesn't use them, for example).

Nothing specific.  Just .... worried.
