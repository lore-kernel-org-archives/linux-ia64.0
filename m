From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 08 Mar 2004 22:41:35 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <200403081541.35189.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com> <200403081505.21644.bjorn.helgaas@hp.com> <16460.61267.364413.100233@napali.hpl.hp.com>
In-Reply-To: <16460.61267.364413.100233@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com, David Mosberger <davidm@napali.hpl.hp.com>
Cc: Russell King <rmk+lkml@arm.linux.org.uk>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, benjamin.liu@intel.com, iod00d@hp.com, kaneshige.kenji@jp.fujitsu.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Monday 08 March 2004 3:10 pm, David Mosberger wrote:
> I agree with Bjorn's reasoning, but think that the patch should be
> tested first on a Big Sur machine (with the latest official firmware).
> If something breaks with old firmware, we can then at least ask the
> affected people to upgrade their firmware (or come up with a kernel
> workaround).

I've tested it on my i2000, and it seems to work fine.  This is with
firmware version

    W460GXBS2.86E.0117C.P09.200108091154

This is the only BIOS version I found mentioned on www.hp.com,
so I assume it's the latest official version.

