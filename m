From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 11 Mar 2004 00:34:06 +0000
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <MDEEKOKJPMPMKGHIFAMAEELHDGAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <16463.30226.948230.439549@napali.hpl.hp.com>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I'm sorry that the report falls behind. I wanted to check out by using
real device driver which uses a probe_irq_on(), but I don't have appropriate
environment now.

Though I didn't check out on a real machine yet, I believe my patch doesn't
have any influence on probe_irq_on() because current probe_irq_on() calls
startup callback to unmask the RTEs as you said before.

Regards,
Kenji Kaneshige

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of David Mosberger
> Sent: Thursday, March 11, 2004 5:10 AM
> To: Kenji Kaneshige
> Cc: linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] fix PCI interrupt setting for ia64
>
>
> Kenji,
>
> Sorry, I lost track of the status of this patch.  Has it been checked
> out OK with respect to interrupt probing?
>
> 	--david
>
> >>>>> On Mon, 08 Mar 2004 11:49:10 +0900, Kenji Kaneshige
> <kaneshige.kenji@jp.fujitsu.com> said:
>
>   Kenji> Hi, In ia64 kernel, IOSAPIC's RTEs for PCI interrupts are
>   Kenji> unmasked at the boot time before installing device drivers. I
>   Kenji> think it is very dangerous.  If some PCI devices without
>   Kenji> device driver generate interrupts, interrupts are generated
>   Kenji> repeatedly because these interrupt requests are never
>   Kenji> cleared. I think RTEs for PCI interrupts should be unmasked
>   Kenji> by device driver.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

