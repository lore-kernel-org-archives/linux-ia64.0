From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 May 2004 21:02:01 +0000
Subject: Re: Kill warnings in 2.6.6
Message-Id: <16555.52041.217534.992132@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
In-Reply-To: <E1BQFaq-0003bB-KT@wombat.disy.cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 May 2004 11:10:00 +1000, Peter Chubb <peterc@gelato.unsw.edu.au> said:

 Peter> === arch/ia64/ia32/ia32_signal.c 1.27 vs edited == Peter> --- 1.27/arch/ia64/ia32/ia32_signal.c	Fri Apr 23 16:38:17 2004
 Peter> +++ edited/arch/ia64/ia32/ia32_signal.c	Tue May 18 13:18:25 2004
 Peter> @@ -173,7 +173,8 @@
 Peter>  		case __SI_MESGQ >> 16:
 Peter>  			err |= __put_user(from->si_uid, &to->si_uid);
 Peter>  			err |= __put_user(from->si_pid, &to->si_pid);
 Peter> -			err |= __put_user(from->si_ptr, &to->si_ptr);
 Peter> +			addr = (unsigned long)from->si_ptr;
 Peter> +			err |= __put_user(addr, &to->si_ptr);
 Peter>  			break;
 Peter>  		}
 Peter>  	}

Hmmh, this one is already in my tree.

  Peter> === arch/ia64/kernel/perfmon.c 1.73 vs edited === ---

I'll leave that to Stephane.

=== include/asm-ia64/unistd.h 1.40 vs edited ==--- 1.40/include/asm-ia64/unistd.h	Thu Apr 15 18:26:53 2004
+++ edited/include/asm-ia64/unistd.h	Tue May 18 12:52:06 2004
@@ -367,12 +367,12 @@
  */
-#define cond_syscall(x) asmlinkage long x() __attribute__((weak,alias("sys_ni_syscall")));
+#define cond_syscall(x) asmlinkage long x(void) __attribute__((weak,alias("sys_ni_syscall")));

Hmmh, the reason the warning got introduced was that there was an
issue that got triggered with the Intel compiler and the stubs
probably should have been delcared properly in a header-file anyhow.
I haven't looked into it recently, but I was hoping that the
introduction of syscall.h would fix this in a clean fashion (i.e.,
without introducing potentionally conflicting declarations).

	--david
