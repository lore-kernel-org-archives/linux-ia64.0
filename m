From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Mon, 08 Mar 2004 09:25:52 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <20040308.182552.55855095.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: benjamin.liu@intel.com
Cc: iod00d@hp.com, kaneshige.kenji@jp.fujitsu.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

From: "Liu, Benjamin" <benjamin.liu@intel.com>
Subject: RE: [PATCH] fix PCI interrupt setting for ia64
Date: Mon, 8 Mar 2004 15:44:16 +0800

> ISA is legacy to IA64. The configuration script of 2.4.23 has
> CONFIG_ISA off explicitly for IA64, 2.6.2 doesn't have this
> option for IA64. I just wonder whether the legacy probing
> method still exists on IA64.

I think that's still true for IDE / serial port drivers.
Kaneshige-san, could you confirm your changes are compatible
with probe_irq_on()?

Itanium-generation machines (such as BigSur) depends on
probe_irq_on() for finding serial port IRQ.

---
Takayoshi Kochi <t-kochi@bq.jp.nec.com>
