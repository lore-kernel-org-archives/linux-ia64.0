From: Jes Sorensen <jes@sgi.com>
Date: Tue, 22 Apr 2008 09:08:22 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <yq08wz6l0jd.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> Make NR_IRQ overridable by each pv instances.
> Pv instance may need each own number of irqs so that
> NR_IRQS should be the maximum number of nr_irqs each
> pv instances need.

This really looks dodgy.

+#ifdef CONFIG_PARAVIRT
+
+/* Determine the maximal NR_IRQ which each pv instances require.
+ * i.e. NR_IRQS = max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, ...)
+ */
+
+#define NR_IRQS 1
+
+#if IA64_NATIVE_NR_IRQS > NR_IRQS
+#undef NR_IRQS
+#define NR_IRQS IA64_NATIVE_NR_IRQS
+#endif
+
+#ifdef CONFIG_XEN
+#include <asm/xen/irq.h>
+#if XEN_NR_IRQS > NR_IRQS
+#undef NR_IRQS
+#define NR_IRQS XEN_NR_IRQS
+#endif
+#endif /* CONFIG_XEN */

I don't see why Xen needs special casing here, it really makes the
code gross. Please use one typedef for this, like PARAVIRT_NR_IRQS or
something like that, so we don't end up with a KVM special case, an
LGUEST special case and a Xen special case.

Cheers,
Jes
