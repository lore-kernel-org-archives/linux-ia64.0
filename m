From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 23 May 2003 01:49:02 +0000
Subject: [Linux-ia64] IA-32 emulation patch: semctl.patch
Message-Id: <marc-linux-ia64-105590723705998@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

semctl doesn't check for bad command.
This patch is in 2.5 already. Bjorn, could you please apply it to 2.4 ?

	-Arun

=== linux-ia64-2.4/arch/ia64/ia32/sys_ia32.c 1.16 vs edited ==--- 1.16/arch/ia64/ia32/sys_ia32.c	Fri Apr 18 10:55:20 2003
+++ edited/linux-ia64-2.4/arch/ia64/ia32/sys_ia32.c	Thu May 22 17:57:38 2003
@@ -2167,6 +2167,9 @@
 	else
 		fourth.__pad = (void *)A(pad);
 	switch (third) {
+	      default:
+		err = -EINVAL;
+		break;
 	      case IPC_INFO:
 	      case IPC_RMID:
 	      case IPC_SET:


