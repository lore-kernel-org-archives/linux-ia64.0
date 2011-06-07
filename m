From: Oleg Nesterov <oleg@redhat.com>
Date: Tue, 07 Jun 2011 17:19:52 +0000
Subject: Re: [PATCH -v2] Audit: push audit success and retcode into arch
Message-Id: <20110607171952.GA25729@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110603220451.23134.47368.stgit@paris.rdu.redhat.com>
In-Reply-To: <20110603220451.23134.47368.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Paris <eparis@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, monstr@monstr.eu, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, richard@nod.at, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

On 06/03, Eric Paris wrote:
>
> The audit system previously expected arches calling to audit_syscall_exit to
> supply as arguments if the syscall was a success and what the return code was.
> Audit also provides a helper AUDITSC_RESULT which was supposed to simplify things
> by converting from negative retcodes to an audit internal magic value stating
> success or failure.  This helper was wrong and could indicate that a valid
> pointer returned to userspace was a failed syscall.  The fix is to fix the
> layering foolishness.  We now pass audit_syscall_exit a struct pt_reg and it
> in turns calls back into arch code to collect the return value and to
> determine if the syscall was a success or failure.  We also define a generic
> is_syscall_success() macro which determines success/failure based on if the
> value is < -MAX_ERRNO.  This works for arches like x86 which do not use a
> separate mechanism to indicate syscall failure.

I know nothing about audit, but the patch looks fine to me.


But I have a bit off-topic question,

> diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
> index 8a445a0..b7b1f88 100644
> --- a/arch/x86/kernel/entry_64.S
> +++ b/arch/x86/kernel/entry_64.S
> @@ -53,6 +53,7 @@
>  #include <asm/paravirt.h>
>  #include <asm/ftrace.h>
>  #include <asm/percpu.h>
> +#include <linux/err.h>
>
>  /* Avoid __ASSEMBLER__'ifying <linux/audit.h> just for this.  */
>  #include <linux/elf-em.h>
> @@ -564,17 +565,16 @@ auditsys:
>  	jmp system_call_fastpath
>
>  	/*
> -	 * Return fast path for syscall audit.  Call audit_syscall_exit()
> +	 * Return fast path for syscall audit.  Call __audit_syscall_exit()
>  	 * directly and then jump back to the fast path with TIF_SYSCALL_AUDIT
>  	 * masked off.
>  	 */
>  sysret_audit:
>  	movq RAX-ARGOFFSET(%rsp),%rsi	/* second arg, syscall return value */
> -	cmpq $0,%rsi		/* is it < 0? */
> -	setl %al		/* 1 if so, 0 if not */
> +	cmpq $-MAX_ERRNO,%rsi	/* is it < -MAX_ERRNO? */
> +	setbe %al		/* 1 if so, 0 if not */
>  	movzbl %al,%edi		/* zero-extend that into %edi */
> -	inc %edi /* first arg, 0->1(AUDITSC_SUCCESS), 1->2(AUDITSC_FAILURE) */
> -	call audit_syscall_exit
> +	call __audit_syscall_exit

With or without this patch, can't we call audit_syscall_exit() twice
if there is something else in _TIF_WORK_SYSCALL_EXIT mask apart from
SYSCALL_AUDIT ? First time it is called from asm, then from
syscall_trace_leave(), no?

For example. The task has TIF_SYSCALL_AUDIT and nothing else, it does
system_call->auditsys->system_call_fastpath. What if it gets, say,
TIF_SYSCALL_TRACE before ret_from_sys_call?

Oleg.

