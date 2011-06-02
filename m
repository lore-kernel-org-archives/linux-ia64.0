From: Richard Weinberger <richard@nod.at>
Date: Thu, 02 Jun 2011 22:32:16 +0000
Subject: Re: [PATCH] Audit: push audit success and retcode into arch ptrace.h
Message-Id: <201106030032.17398.richard@nod.at>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110602210458.23613.24076.stgit@paris.rdu.redhat.com>
In-Reply-To: <20110602210458.23613.24076.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Eric Paris <eparis@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, monstr@monstr.eu, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, oleg@redhat.com, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

Am Donnerstag 02 Juni 2011, 23:04:58 schrieb Eric Paris:
> b/arch/um/sys-i386/shared/sysdep/ptrace.h index d50e62e..ef5c310 100644
> --- a/arch/um/sys-i386/shared/sysdep/ptrace.h
> +++ b/arch/um/sys-i386/shared/sysdep/ptrace.h
> @@ -162,6 +162,7 @@ struct syscall_args {
>  #define UPT_ORIG_SYSCALL(r) UPT_EAX(r)
>  #define UPT_SYSCALL_NR(r) UPT_ORIG_EAX(r)
>  #define UPT_SYSCALL_RET(r) UPT_EAX(r)
> +#define regs_return_value UPT_SYSCALL_RET

This does not work at all.
UPT_SYSCALL_RET expects something of type struct uml_pt_regs.

#define regs_return_value REGS_EAX
Would be correct. (For x86_64 it needs to be REGS_RAX)

But there seems to be another problem.
Why is pt_regs of type void *?

gcc complains:
In file included from include/linux/fsnotify.h:15:0,
                 from include/linux/security.h:26,
                 from init/main.c:32:
include/linux/audit.h: In function ‘audit_syscall_exit’:
include/linux/audit.h:440:17: warning: dereferencing ‘void *’ pointer
include/linux/audit.h:440:3: error: invalid use of void expression
include/linux/audit.h:441:21: warning: dereferencing ‘void *’ pointer
include/linux/audit.h:441:21: error: void value not ignored as it ought to be

Thanks,
//richard
