From: Jes Sorensen <jes@sgi.com>
Date: Thu, 24 Apr 2008 11:52:20 +0000
Subject: Re: [PATCH 11/15] ia64/pv_ops: paravirtualize NR_IRQS
Message-Id: <48107474.8010400@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549755-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549755-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> On Wed, Apr 23, 2008 at 04:03:58PM +0200, Jes Sorensen wrote:
>> Isaku Yamahata wrote:
>>>> I'd rather have PARAVIRT_NR_IRQ set from Kconfig if possible given that
>>>> all of these are constants anyway. If we cannot do that, then it would
>>>> be better to do the #if FOO_NR_IRQ > PARAVIRT_NR_IRQ in the various
>>>> header files for Xen/KVM/lguest so we don't get the clutter in the main
>>>> makefile.
>>> Unfotunately Kconfig doesn't support arithmetic comparison.
>>> So do you want something like the followings?
>> IMHO, that would be better.
> 
> How about this?
> Eventually I found another way which doesn't use #undef trick.
> ASM_OFFSET_C is somewhat tricky, but much better, I suppose.

Hi Isaku,

Yes, this looks like a much nicer way to solve the problem IMHO.

> +/*
> + * PARAVIRT_NR_IRQS is defined by asm-offsets.c as
> + * max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, ...) depending on config.
> + */
> +#ifndef ASM_OFFSETS_C
> +#include <asm/asm-offsets.h>
> +#define NR_IRQS	PARAVIRT_NR_IRQS
>  #endif
>  
>  static __inline__ int

Shouldn't this be defined as IA64_NATIVE_NR_IRQS? I wouldn't do the
#ifndef ASM_OFFSETS_C part, you should be able to just include it
unconditionally.

Cheers,
Jes
