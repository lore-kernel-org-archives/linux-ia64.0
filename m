From: Jes Sorensen <jes@sgi.com>
Date: Tue, 22 Apr 2008 12:05:59 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <480DD4A7.9020207@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> I'm willing to introduce something like PARAVIRT_NR_IRQS,
> but I don't see how PARAVIRT_NR_IRQS solves the issues.
> What I want here is to define by cpp
> #define PARAVIRT_NR_IRQS                                                \
>         max(                                                            \
>                 IA64_NATIVE_NR_IRQS,                                    \
>                 XEN_NR_IRQS,            /* only if CONFIG_XEN */        \
>                 LGUSET_NR_IRQS,         /* only if CONFIG_LGUSET */     \
>                 KVM_GUEST_NR_IRQS,      /* only if CONFIG_KVM_GUEST */  \
>                 MORE_FUTURE_VM_NR_IRQS, /* only if ...*/                \
>                 ....    \
>         )
> 
> Probably I'm missing something.
> Could you suggest more concretly? Hopefully (pseudo) code snippet.

I'd rather have PARAVIRT_NR_IRQ set from Kconfig if possible given that
all of these are constants anyway. If we cannot do that, then it would
be better to do the #if FOO_NR_IRQ > PARAVIRT_NR_IRQ in the various
header files for Xen/KVM/lguest so we don't get the clutter in the main
makefile.

Cheers,
Jes

