From: Arun Sharma <arun.sharma@intel.com>
Date: Mon, 08 Sep 2003 23:56:00 +0000
Subject: MINSIGSTKSZ on ia32
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------080409030107030701030007"
Message-Id: <marc-linux-ia64-106306553008889@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------080409030107030701030007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


MINSIGSTKSZ is defined differently for i386 and ia64. This patch improves compatibility with apps which use sigaltstack(2) with sizes between MINSIGSTKSZ_IA32 and MINSIGSTKSZ.

Patches for both 2.4 and 2.6 are attached.

	-Arun


--------------080409030107030701030007
Content-Type: text/plain;
 name="sigaltstk-2.4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sigaltstk-2.4.patch"

Index: linux-2.4/arch/ia64/ia32/sys_ia32.c
===================================================================
--- linux-2.4/arch/ia64/ia32/sys_ia32.c	(revision 8)
+++ linux-2.4/arch/ia64/ia32/sys_ia32.c	(working copy)
@@ -75,6 +75,7 @@
 #define OFFSET4K(a)		((a) & 0xfff)
 #define PAGE_START(addr)	((addr) & PAGE_MASK)
 #define PAGE_OFF(addr)		((addr) & ~PAGE_MASK)
+#define MINSIGSTKSZ_IA32	2048
 
 extern asmlinkage long sys_execve (char *, char **, char **, struct pt_regs *);
 extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
@@ -3408,10 +3409,18 @@
 			return -EFAULT;
 	uss.ss_sp = (void *) (long) buf32.ss_sp;
 	uss.ss_flags = buf32.ss_flags;
-	uss.ss_size = buf32.ss_size;
+	/* MINSIGSTKSZ is different for ia32 vs ia64. We lie here to pass the 
+           check and set it to the user requested value later */
+	if (buf32.ss_size < MINSIGSTKSZ_IA32) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	uss.ss_size = MINSIGSTKSZ;
 	set_fs(KERNEL_DS);
 	ret = do_sigaltstack(uss32 ? &uss : NULL, &uoss, pt->r12);
+ 	current->sas_ss_size = buf32.ss_size;	
 	set_fs(old_fs);
+out:
 	if (ret < 0)
 		return(ret);
 	if (uoss32) {

--------------080409030107030701030007
Content-Type: text/plain;
 name="sigaltstk-2.6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sigaltstk-2.6.patch"

Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
===================================================================
--- linux-2.6/arch/ia64/ia32/sys_ia32.c	(revision 13148)
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c	(working copy)
@@ -76,6 +76,7 @@
 
 #define OFFSET4K(a)		((a) & 0xfff)
 #define PAGE_START(addr)	((addr) & PAGE_MASK)
+#define MINSIGSTKSZ_IA32	2048
 
 #define high2lowuid(uid) ((uid) > 65535 ? 65534 : (uid))
 #define high2lowgid(gid) ((gid) > 65535 ? 65534 : (gid))
@@ -2262,10 +2263,18 @@
 			return -EFAULT;
 	uss.ss_sp = (void *) (long) buf32.ss_sp;
 	uss.ss_flags = buf32.ss_flags;
-	uss.ss_size = buf32.ss_size;
+	/* MINSIGSTKSZ is different for ia32 vs ia64. We lie here to pass the 
+           check and set it to the user requested value later */
+	if (buf32.ss_size < MINSIGSTKSZ_IA32) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	uss.ss_size = MINSIGSTKSZ;
 	set_fs(KERNEL_DS);
 	ret = do_sigaltstack(uss32 ? &uss : NULL, &uoss, pt->r12);
+ 	current->sas_ss_size = buf32.ss_size;	
 	set_fs(old_fs);
+out:
 	if (ret < 0)
 		return(ret);
 	if (uoss32) {

--------------080409030107030701030007--

