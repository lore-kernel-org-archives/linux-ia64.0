From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 23 May 2003 01:39:33 +0000
Subject: [Linux-ia64] IA-32 emulation patch: rlim.patch
Message-Id: <marc-linux-ia64-105590723705996@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

rlim_cur/rlim_max should be defined as unsigned integers to be
compatible with native i386.

	-Arun

=== linux-ia64-2.4/arch/ia64/ia32/sys_ia32.c 1.16 vs edited ==--- 1.16/arch/ia64/ia32/sys_ia32.c	Fri Apr 18 10:55:20 2003
+++ edited/linux-ia64-2.4/arch/ia64/ia32/sys_ia32.c	Thu May 22 17:51:06 2003
@@ -1230,8 +1230,8 @@
 #define RESOURCE32(x) ((x > RLIM_INFINITY32) ? RLIM_INFINITY32 : x)
 
 struct rlimit32 {
-	int	rlim_cur;
-	int	rlim_max;
+	unsigned int	rlim_cur;
+	unsigned int	rlim_max;
 };
 
 extern asmlinkage long sys_getrlimit (unsigned int resource, struct rlimit *rlim);


