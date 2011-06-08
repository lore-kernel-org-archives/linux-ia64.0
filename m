From: Oleg Nesterov <oleg@redhat.com>
Date: Wed, 08 Jun 2011 19:19:10 +0000
Subject: Re: [PATCH -v2] Audit: push audit success and retcode into arch
Message-Id: <20110608191910.GA18698@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110603220451.23134.47368.stgit@paris.rdu.redhat.com> <20110607171952.GA25729@redhat.com> <1307472796.2052.12.camel@localhost.localdomain> <20110608163653.GA9592@redhat.com> <1307556823.2577.5.camel@localhost.localdomain> <20110608183720.GA16883@redhat.com>
In-Reply-To: <20110608183720.GA16883@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Paris <eparis@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, monstr@monstr.eu, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, richard@nod.at, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

On 06/08, Oleg Nesterov wrote:
>
> OK. Thanks a lot Eric for your explanations.

Yes. but may I ask another one?

Shouldn't copy_process()->audit_alloc(tsk) path do
clear_tsk_thread_flag(tsk, TIF_SYSCALL_AUDIT) if it doesn't
set tsk->audit_context?

I can be easily wrong, but afaics otherwise the child can run
with TIF_SYSCALL_AUDIT bit copied from parent's thread_info by
dup_task_struct()->setup_thread_stack() and without ->audit_context,
right? For what?

Any other reason why audit_syscall_entry() checks context != NULL?

IOW. Any reason the patch below is wrong?

I am just curious, thanks.

Oleg.

--- x/kernel/auditsc.c
+++ x/kernel/auditsc.c
@@ -885,6 +885,8 @@ int audit_alloc(struct task_struct *tsk)
 	if (likely(!audit_ever_enabled))
 		return 0; /* Return if not auditing. */
 
+	clear_tsk_thread_flag(tsk, TIF_SYSCALL_AUDIT);
+
 	state = audit_filter_task(tsk, &key);
 	if (likely(state = AUDIT_DISABLED))
 		return 0;
@@ -1591,9 +1593,7 @@ void audit_syscall_entry(int arch, int m
 	struct audit_context *context = tsk->audit_context;
 	enum audit_state     state;
 
-	if (unlikely(!context))
-		return;
-
+	BUG_ON(!context);
 	/*
 	 * This happens only on certain architectures that make system
 	 * calls in kernel_thread via the entry.S interface, instead of

