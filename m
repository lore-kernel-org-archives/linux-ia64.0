From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 23 Apr 2008 02:54:14 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <20080423025414.GA7679%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 22, 2008 at 02:05:59PM +0200, Jes Sorensen wrote:
> Isaku Yamahata wrote:
> >I'm willing to introduce something like PARAVIRT_NR_IRQS,
> >but I don't see how PARAVIRT_NR_IRQS solves the issues.
> >What I want here is to define by cpp
> >#define PARAVIRT_NR_IRQS                                                \
> >        max(                                                            \
> >                IA64_NATIVE_NR_IRQS,                                    \
> >                XEN_NR_IRQS,            /* only if CONFIG_XEN */        \
> >                LGUSET_NR_IRQS,         /* only if CONFIG_LGUSET */     \
> >                KVM_GUEST_NR_IRQS,      /* only if CONFIG_KVM_GUEST */  \
> >                MORE_FUTURE_VM_NR_IRQS, /* only if ...*/                \
> >                ....    \
> >        )
> >
> >Probably I'm missing something.
> >Could you suggest more concretly? Hopefully (pseudo) code snippet.
> 
> I'd rather have PARAVIRT_NR_IRQ set from Kconfig if possible given that
> all of these are constants anyway. If we cannot do that, then it would
> be better to do the #if FOO_NR_IRQ > PARAVIRT_NR_IRQ in the various
> header files for Xen/KVM/lguest so we don't get the clutter in the main
> makefile.

Unfotunately Kconfig doesn't support arithmetic comparison.
So do you want something like the followings?

irq.h:

#if (NR_VECTORS + 32 * NR_CPUS) < 1024
#define IA64_NATIVE_NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
#else
#define IA64_NATIVE_NR_IRQS 1024
#endif

#define PARAVIRT_NR_IRQS	IA64_NATIVE_NR_IRQS
/* CAUTION:each asm/xxx/irq.h may redefine PARAVIRT_NR_IRQS */
#include <asm/xen/irq.h>
#include <asm/kvm/irq.h>
#include <asm/foo/irq.h>
...

#define NR_IRQS			PARAVIRT_NR_IRQS


asm/foo/irq.h:

#define FOO_NR_IRQ	...

#ifdef CONFIG_FOO
#if FOO_NR_IRQS > PARAVIRT_NR_IRQS
#undef PARAVIRT_NR_IRQS
#define PARAVIRT_NR_IRQS FOO_NR_IRQS
#endif
#endif


-- 
yamahata
