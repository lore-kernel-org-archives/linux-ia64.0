From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 18 Jun 2004 14:32:17 +0000
Subject: Re: sys_ioctl export
Message-Id: <200406181032.17967.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_xzv0APjDTljeFBu"
List-Id: <linux-ia64.vger.kernel.org>
References: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
In-Reply-To: <1087494747.28235.28.camel@markh1.pdx.osdl.net>
To: linux-ia64@vger.kernel.org


--Boundary-00=_xzv0APjDTljeFBu
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday, June 18, 2004 2:54 am, Christoph Hellwig wrote:
> On Thu, Jun 17, 2004 at 02:25:16PM -0700, David Mosberger wrote:
> > >>>>> On Thu, 17 Jun 2004 12:36:54 -0700, Mark Haverkamp <markh@osdl.org>
> > >>>>> said:
> >
> >   Mark> Wouldn't there be some reluctance to export a symbol to
> >   Mark> everyone when it is only used for a special purpose?
> >
> > It seems rather silly to try to limit the exporting of a symbol that's
> > exported for all 64-bit platforms.  But I don't really care.  If you
> > want to submit a tested patch to add the symbol to ia64_ksyms.c, I can
> > certainly live with that.
>
> Just put the export into common code and guard it by CONFIG_COMPAT, matches
> exactly the intended users.

Like this totally untested and uncompiled patch?

Jesse


--Boundary-00=_xzv0APjDTljeFBu
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="sys-ioctl-export.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sys-ioctl-export.patch"

===== arch/ppc64/kernel/ppc_ksyms.c 1.40 vs edited =====
--- 1.40/arch/ppc64/kernel/ppc_ksyms.c	2004-04-12 13:54:03 -04:00
+++ edited/arch/ppc64/kernel/ppc_ksyms.c	2004-06-18 10:28:45 -04:00
@@ -50,7 +50,6 @@
 int abs(int);
 
 EXPORT_SYMBOL(do_signal);
-EXPORT_SYMBOL(sys_ioctl);
 
 EXPORT_SYMBOL(isa_io_base);
 EXPORT_SYMBOL(pci_io_base);
===== arch/s390/kernel/s390_ksyms.c 1.23 vs edited =====
--- 1.23/arch/s390/kernel/s390_ksyms.c	2004-06-12 23:52:29 -04:00
+++ edited/arch/s390/kernel/s390_ksyms.c	2004-06-18 10:28:58 -04:00
@@ -76,4 +76,3 @@
 EXPORT_SYMBOL_NOVERS(do_call_softirq);
 EXPORT_SYMBOL(sys_wait4);
 EXPORT_SYMBOL(cpcmd);
-EXPORT_SYMBOL(sys_ioctl);
===== arch/sparc64/kernel/sparc64_ksyms.c 1.69 vs edited =====
--- 1.69/arch/sparc64/kernel/sparc64_ksyms.c	2004-06-09 01:29:44 -04:00
+++ edited/arch/sparc64/kernel/sparc64_ksyms.c	2004-06-18 10:29:12 -04:00
@@ -327,7 +327,6 @@
 EXPORT_SYMBOL(sys_getgid);
 EXPORT_SYMBOL(svr4_getcontext);
 EXPORT_SYMBOL(svr4_setcontext);
-EXPORT_SYMBOL(sys_ioctl);
 EXPORT_SYMBOL(compat_sys_ioctl);
 EXPORT_SYMBOL(sparc32_open);
 EXPORT_SYMBOL(sys_close);
===== arch/x86_64/kernel/x8664_ksyms.c 1.32 vs edited =====
--- 1.32/arch/x86_64/kernel/x8664_ksyms.c	2004-05-17 17:12:13 -04:00
+++ edited/arch/x86_64/kernel/x8664_ksyms.c	2004-06-18 10:29:26 -04:00
@@ -218,4 +218,3 @@
 EXPORT_SYMBOL_GPL(flush_tlb_all);
 #endif
 
-EXPORT_SYMBOL(sys_ioctl);
===== fs/ioctl.c 1.12 vs edited =====
--- 1.12/fs/ioctl.c	2004-05-29 14:22:13 -04:00
+++ edited/fs/ioctl.c	2004-06-18 10:30:30 -04:00
@@ -4,11 +4,13 @@
  *  Copyright (C) 1991, 1992  Linus Torvalds
  */
 
+#include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/smp_lock.h>
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/security.h>
+#include <linux/module.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -133,3 +135,7 @@
 out:
 	return error;
 }
+
+#ifdef CONFIG_COMPAT
+EXPORT_SYMBOL(sys_ioctl);
+#endif

--Boundary-00=_xzv0APjDTljeFBu--
