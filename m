From: Tony Luck <tony.luck@intel.com>
Date: Thu, 02 Jun 2011 23:00:51 +0000
Subject: Re: [PATCH] Audit: push audit success and retcode into arch ptrace.h
Message-Id: <BANLkTik9kCs_06=7HKo44cWqpS0zB9fr+A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110602210458.23613.24076.stgit@paris.rdu.redhat.com>
        <201106030032.17398.richard@nod.at>
In-Reply-To: <201106030032.17398.richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Richard Weinberger <richard@nod.at>
Cc: Eric Paris <eparis@redhat.com>, linux-kernel@vger.kernel.org, fenghua.yu@intel.com, monstr@monstr.eu, ralf@linux-mips.org, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, jdike@addtoit.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, oleg@redhat.com, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net

> But there seems to be another problem.
> Why is pt_regs of type void *?
>
> gcc complains:
> In file included from include/linux/fsnotify.h:15:0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 from include/linux/security.h:26,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 from init/main.c:32:
> include/linux/audit.h: In function =91audit_syscall_exit=92:
> include/linux/audit.h:440:17: warning: dereferencing =91void *=92 pointer
> include/linux/audit.h:440:3: error: invalid use of void expression
> include/linux/audit.h:441:21: warning: dereferencing =91void *=92 pointer
> include/linux/audit.h:441:21: error: void value not ignored as it ought t=
o be

Perhaps same issue on ia64 - but symptoms are different:

  CC      crypto/cipher.o
In file included from include/linux/fsnotify.h:15,
                 from include/linux/security.h:26,
                 from init/do_mounts.c:8:
include/linux/audit.h: In function =91audit_syscall_exit=92:
include/linux/audit.h:440: warning: dereferencing =91void *=92 pointer
include/linux/audit.h:440: error: request for member =91r10=92 in
something not a structure or union
include/linux/audit.h:441: error: request for member =91r10=92 in
something not a structure or union
include/linux/audit.h:441: error: request for member =91r8=92 in something
not a structure or union
include/linux/audit.h:441: error: request for member =91r8=92 in something
not a structure or union
include/linux/audit.h:441: error: expected =91;=92 before =91}=92 token
include/linux/audit.h:441: error: void value not ignored as it ought to be

-Tony
