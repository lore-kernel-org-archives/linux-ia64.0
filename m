From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 22 Apr 2008 10:11:13 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <20080422101113.GH28863%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 22, 2008 at 05:08:22AM -0400, Jes Sorensen wrote:
> 
> > Make NR_IRQ overridable by each pv instances.
> > Pv instance may need each own number of irqs so that
> > NR_IRQS should be the maximum number of nr_irqs each
> > pv instances need.
> 
> This really looks dodgy.
> 
> +#ifdef CONFIG_PARAVIRT
> +
> +/* Determine the maximal NR_IRQ which each pv instances require.
> + * i.e. NR_IRQS = max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, ...)
> + */
> +
> +#define NR_IRQS 1
> +
> +#if IA64_NATIVE_NR_IRQS > NR_IRQS
> +#undef NR_IRQS
> +#define NR_IRQS IA64_NATIVE_NR_IRQS
> +#endif
> +
> +#ifdef CONFIG_XEN
> +#include <asm/xen/irq.h>
> +#if XEN_NR_IRQS > NR_IRQS
> +#undef NR_IRQS
> +#define NR_IRQS XEN_NR_IRQS
> +#endif
> +#endif /* CONFIG_XEN */
> 
> I don't see why Xen needs special casing here, it really makes the
> code gross. Please use one typedef for this, like PARAVIRT_NR_IRQS or
> something like that, so we don't end up with a KVM special case, an
> LGUEST special case and a Xen special case.

I'm willing to introduce something like PARAVIRT_NR_IRQS,
but I don't see how PARAVIRT_NR_IRQS solves the issues.
What I want here is to define by cpp
#define PARAVIRT_NR_IRQS                                                \
        max(                                                            \
                IA64_NATIVE_NR_IRQS,                                    \
                XEN_NR_IRQS,            /* only if CONFIG_XEN */        \
                LGUSET_NR_IRQS,         /* only if CONFIG_LGUSET */     \
                KVM_GUEST_NR_IRQS,      /* only if CONFIG_KVM_GUEST */  \
                MORE_FUTURE_VM_NR_IRQS, /* only if ...*/                \
                ....    \
        )

Probably I'm missing something.
Could you suggest more concretly? Hopefully (pseudo) code snippet.

-- 
yamahata
