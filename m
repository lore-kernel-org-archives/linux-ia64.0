From: Hironobu Ishii <ishii.hironobu@jp.fujitsu.com>
Date: Wed, 28 Jan 2004 01:54:42 +0000
Subject: [RFC/PATCH, 3/4] readX_check() performance evaluation
Message-Id: <00a401c3e541$c1d347f0$2987110a@lsd.css.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

This is a patch for rawread 1.0.3.
Original rawread 1.0.3 depends on i386.

Thanks, 
Hironobu Ishii

--- rawread.c.old 2004-01-22 19:33:43.000000000 +0900
+++ rawread.c 2004-01-27 23:26:24.406717936 +0900
@@ -94,8 +94,14 @@
 
 __inline__ unsigned long long int rdtsc()
 {
-  unsigned long long int x;
-  __asm__ volatile (".byte 0x0f, 0x31" : "=A" (x));
+ unsigned long long int x;
+#if __i386__
+ __asm__ volatile (".byte 0x0f, 0x31" : "=A" (x));
+#elif __ia64__
+ __asm__ volatile ("mov r8 = ar44");
+#else
+ #error "Please write your own rdtsc()"
+#endif
   return x;
 }
 

