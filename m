From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 06 Mar 2003 21:55:51 +0000
Subject: Re: [Linux-ia64] [PATCH] IA32 support without sysctl doesn't work
Message-Id: <marc-linux-ia64-105590709805990@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805797@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805797@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The ia32 subsystem should mirror what's done in kernel/sysctl.c: when
> CONFIG_SYSCTL isn't defined, there should be a dummy sys32_sysctl().
> That way, the number of #ifdefs is localized to one file.

I applied the following patch to 2.4:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1009.1.5 -> 1.1009.1.6
#	arch/ia64/ia32/sys_ia32.c	1.16    -> 1.16.1.1
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/03/06	bjorn_helgaas@hp.com	1.1009.1.6
# ia64: Make CONFIG_SYSCTL control sys32_sysctl as well.  Based on a
# patch from Peter Chubb.
# --------------------------------------------
#
diff -Nru a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
--- a/arch/ia64/ia32/sys_ia32.c	Thu Mar  6 14:40:13 2003
+++ b/arch/ia64/ia32/sys_ia32.c	Thu Mar  6 14:40:13 2003
@@ -3407,6 +3407,7 @@
 asmlinkage long
 sys32_sysctl (struct sysctl32 *args)
 {
+#ifdef CONFIG_SYSCTL
 	struct sysctl32 a32;
 	mm_segment_t old_fs = get_fs ();
 	void *oldvalp, *newvalp;
@@ -3444,6 +3445,9 @@
 		return -EFAULT;
 
 	return ret;
+#else
+	return -ENOSYS;
+#endif
 }
 
 asmlinkage long


