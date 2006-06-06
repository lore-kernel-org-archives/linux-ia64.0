From: Jes Sorensen <jes@sgi.com>
Date: Tue, 06 Jun 2006 09:33:05 +0000
Subject: Re: [RFC 2/2][2/4] Xen/ia64 added files
Message-Id: <yq0slmisk6m.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149281162.5998.113.camel@lappy>
In-Reply-To: <1149281162.5998.113.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alex" = Alex Williamson <alex.williamson@hp.com> writes:

Alex>    New headers...

New comments :)

Cheers,
Jes


diff -r 016512c08f6b -r 4489a633a5de arch/ia64/xen/xenminstate.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/arch/ia64/xen/xenminstate.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,369 @@
+#include <linux/config.h>

License?

+#include <asm/cache.h>
+
+#ifdef CONFIG_XEN
+#include "../kernel/entry.h"
+#else
+#include "entry.h"
+#endif

Maybe it's time to move these to include/asm and do it in a clean way.

+/*
+ * For ivt.s we want to access the stack virtually so we don't have to disable translation
+ * on interrupts.

80 columns - applies all the way below too.

+ * Note that psr.ic is NOT turned on by this macro.  This is so that
+ * we can pass interruption state as arguments to a handler.
+ */
+#ifdef CONFIG_XEN
+#define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							\

Seperate files perhaps?


diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/fixmap.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/fixmap.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,2 @@
+#define clear_fixmap(x)	do {} while (0)
+#define	set_fixmap(x,y)	do {} while (0)

????? license?


+static inline int
+HYPERVISOR_sched_op_compat(
+    int cmd, unsigned long arg)
+{
+	return _hypercall2(int, sched_op_compat, cmd, arg);
+}

StuUuUuUuDlY!

--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/hypervisor.h	Fri Jun 02 09:54:29 2006 -0600
+#ifndef __HYPERVISOR_H__
+#define __HYPERVISOR_H__
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/errno.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/dom0_ops.h>
+#include <xen/interface/event_channel.h>
+#include <xen/interface/physdev.h>
+#include <xen/interface/sched.h>
+#include <asm/hypercall.h>
+#include <asm/ptrace.h>
+#include <asm/page.h>
+#include <asm/xen/privop.h> // for is_running_on_xen()

Thats a lot of includes, are they really all used within this file?

diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/synch_bitops.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/synch_bitops.h	Fri Jun 02 09:54:29 2006 -0600
[snip]
+#include <linux/config.h>
+
+#define ADDR (*(volatile long *) addr)

?????

+#define xen_ssm_i()							\
+({									\
+	int old = xen_get_virtual_psr_i();				\
+	xen_set_virtual_psr_i(1);					\
+	if (!old && xen_get_virtual_pend()) xen_hyper_ssm_i();		\
+})

ARGH! No code on the same line as the if (). Standard CodingSyle
practice.

+#define xen_ia64_intrin_local_irq_restore(x)				\
+{									\
+     if (is_running_on_xen()) {						\
+	if ((x) & IA64_PSR_I) { xen_ssm_i(); }				\
+	else { xen_rsm_i(); }						\
+    }									\
+    else __ia64_intrin_local_irq_restore((x));				\

Ditto and for the else!
