From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 02 Jun 2011 21:18:34 +0000
Subject: Re: [PATCH] Audit: push audit success and retcode into arch ptrace.h
Message-Id: <4DE7FE2A.10107@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110602210458.23613.24076.stgit@paris.rdu.redhat.com>
In-Reply-To: <20110602210458.23613.24076.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Paris <eparis@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, monstr@monstr.eu, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, richard@nod.at, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, viro@zeniv.linux.org.uk, oleg@redhat.com, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

On 06/02/2011 02:04 PM, Eric Paris wrote:
> The audit system previously expected arches calling to audit_syscall_exit to
> supply as arguments if the syscall was a success and what the return code was.
> Audit also provides a helper AUDITSC_RESULT which was supposed to simplify by
> converting from negative retcodes to an audit internal magic value stating
> success or failure.  This helper was wrong and could indicate that a valid
> pointer returned to userspace was a failed syscall.  The fix is to fix the
> layering foolishness.  We now pass audit_syscall_exit a struct pt_reg and it
> in turns calls back into arch code to collect the return value and to
> determine if the syscall was a success or failure.
> 
> In arch/sh/kernel/ptrace_64.c I see that we were using regs[9] in the old
> audit code.  But the ptrace_64.h code was previously using regs[3] for the
> regs_return_value().  I have no idea which one is correct, but this patch now
> uses regs[3].
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

For the x86 portions:

Acked-by: H. Peter Anvin <hpa@zytor.com>

	-hpa
