From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 02 Jun 2001 03:11:11 +0000
Subject: [Linux-ia64] [PATCH] fix for ia32 lseek()
Message-Id: <marc-linux-ia64-105590693005685@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch fixes the IA-32 version of lseek() so it works for
negative values of "offset".  Without this fix, profile-based feedback
doesn't work in the Intel compiler.

	--david

diff -urN ../lia64/arch/ia64/ia32/ia32_entry.S arch/ia64/ia32/ia32_entry.S
--- ../lia64/arch/ia64/ia32/ia32_entry.S	Mon Apr 30 17:24:30 2001
+++ arch/ia64/ia32/ia32_entry.S	Fri Jun  1 16:06:13 2001
@@ -140,7 +140,7 @@
 	data8 sys_lchown
 	data8 sys32_ni_syscall	  /* old break syscall holder */
 	data8 sys32_ni_syscall
-	data8 sys_lseek
+	data8 sys32_lseek
 	data8 sys_getpid	  /* 20 */
 	data8 sys_mount
 	data8 sys_oldumount
diff -urN ../lia64/arch/ia64/ia32/sys_ia32.c arch/ia64/ia32/sys_ia32.c
--- ../lia64/arch/ia64/ia32/sys_ia32.c	Wed May  2 14:56:02 2001
+++ arch/ia64/ia32/sys_ia32.c	Fri Jun  1 16:09:54 2001
@@ -2784,6 +2784,13 @@
 	return ret;
 }
 
+int
+sys32_lseek (int fd, int offset, int whence)
+{
+	/* Sign-extension of "offset" is important here... */
+	return sys_lseek(fd, offset, whence);
+}
+
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
 
 /* In order to reduce some races, while at the same time doing additional

