From: "Jose Luu" <jluu@mainsoft.com>
Date: Thu, 26 Jul 2001 17:34:47 +0000
Subject: [Linux-ia64] patch ia32 mode [Threads don't wake up in ia32 mode]
Message-Id: <marc-linux-ia64-105590693005927@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the solution to the problem I described in june,

see test case there:
https://external-lists.valinux.com/archives//linux-ia64/2001-June/001792.htm
l

There was an oversight on the size of the long, which caused an improper
restoration of the real time signals blocking mask of the 32 bit frame, 2 of
these signals are used by the pthreads library for wakeup or cancellation.

This patch can be applied to all 2.4.x series kernels including 2.4.7, since
the file has not changed.

Jose


--- 2.4.5/arch/ia64/ia32/ia32_signal.c  Tue Oct 10 02:54:53 2000
+++ new-2.4.5/arch/ia64/ia32/ia32_signal.c      Thu Jul 26 12:49:42 2001
@@ -279,7 +279,7 @@
        err |= setup_sigcontext_ia32(&frame->sc, &frame->fpstate, regs,
set->sig[0]);

        if (_IA32_NSIG_WORDS > 1) {
-               err |= __copy_to_user(frame->extramask, &set->sig[1],
+               err |= __copy_to_user(frame->extramask,(((char *) &set->sig)
+ 4) ,
                                      sizeof(frame->extramask));
        }



