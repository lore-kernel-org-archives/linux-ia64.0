From: Jason Baron <jbaron@redhat.com>
Date: Thu, 03 Jun 2004 12:17:43 +0000
Subject: [PATCH] __ARCH_WANT_SYS_SIGPROCMASK
Message-Id: <Pine.LNX.4.44.0406030810070.11780-100000@dhcp64-180.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


hi,

The __ARCH_WANT_SYS_SIGPROCMASK #ifdef wraps the definition of both
sys_sigprocmask as well as sys_rt_sigaction. I think it should probably
only include the former. In any case, if CONFIG_IA32_SUPPORT is not set
the build can't find the sys_rt_sigaction symbol as
__ARCH_WANT_SYS_SIGPROCMASK is not definied in this case. The patch below,
makes the #ifdef only apply to sys_sigprocmask. I've verfied that this
patch does not break x86, ppc, x86_64, and of course fixes ia64 builds
when CONFIG_IA32_SUPPORT is not set.

thanks,

-Jason

--- linux-2.6.6/kernel/signal.c.bak	Wed Jun  2 17:49:14 2004
+++ linux-2.6.6/kernel/signal.c	Wed Jun  2 17:49:45 2004
@@ -2512,6 +2512,8 @@ out:
 	return error;
 }
 
+#endif /* SIGPROCMASK */
+
 #ifndef __sparc__
 asmlinkage long
 sys_rt_sigaction(int sig,
@@ -2541,7 +2543,6 @@ out:
 	return ret;
 }
 #endif /* __sparc__ */
-#endif
 
 #ifdef __ARCH_WANT_SYS_SGETMASK
 

