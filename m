From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 08 Mar 2004 10:46:45 +0000
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <MDEEKOKJPMPMKGHIFAMAEEDEDGAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20040308.182552.55855095.t-kochi@bq.jp.nec.com>
References: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <MDEEKOKJPMPMKGHIFAMAKECGDGAA.kaneshige.kenji@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, benjamin.liu@intel.com
Cc: iod00d@hp.com, kaneshige.kenji@jp.fujitsu.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

> Kaneshige-san, could you confirm your changes are compatible
> with probe_irq_on()?

OK. I'll confirm.

> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org
> [mailto:linux-kernel-owner@vger.kernel.org]On Behalf Of Takayoshi Kochi
> Sent: Monday, March 08, 2004 6:26 PM
> To: benjamin.liu@intel.com
> Cc: iod00d@hp.com; kaneshige.kenji@jp.fujitsu.com;
> linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH] fix PCI interrupt setting for ia64
>
>
> Hi,
>
> From: "Liu, Benjamin" <benjamin.liu@intel.com>
> Subject: RE: [PATCH] fix PCI interrupt setting for ia64
> Date: Mon, 8 Mar 2004 15:44:16 +0800
>
> > ISA is legacy to IA64. The configuration script of 2.4.23 has
> > CONFIG_ISA off explicitly for IA64, 2.6.2 doesn't have this
> > option for IA64. I just wonder whether the legacy probing
> > method still exists on IA64.
>
> I think that's still true for IDE / serial port drivers.
> Kaneshige-san, could you confirm your changes are compatible
> with probe_irq_on()?
>
> Itanium-generation machines (such as BigSur) depends on
> probe_irq_on() for finding serial port IRQ.
>
> ---
> Takayoshi Kochi <t-kochi@bq.jp.nec.com>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

