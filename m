From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Mar 2004 22:50:30 +0000
Subject: Re: [PATCH] fix PCI interrupt setting for ia64
Message-Id: <16460.63670.103003.460158@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401B1A017@PDSMSX403.ccr.corp.intel.com>
	<200403081505.21644.bjorn.helgaas@hp.com>
	<16460.61267.364413.100233@napali.hpl.hp.com>
	<200403081541.35189.bjorn.helgaas@hp.com>
In-Reply-To: <200403081541.35189.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: davidm@hpl.hp.com, David Mosberger <davidm@napali.hpl.hp.com>, Russell King <rmk+lkml@arm.linux.org.uk>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, benjamin.liu@intel.com, iod00d@hp.com, kaneshige.kenji@jp.fujitsu.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Mon, 8 Mar 2004 15:41:35 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> I've tested it on my i2000, and it seems to work fine.  This
  Bjorn> is with firmware version

  Bjorn>     W460GXBS2.86E.0117C.P09.200108091154

  Bjorn> This is the only BIOS version I found mentioned on
  Bjorn> www.hp.com, so I assume it's the latest official version.

I'm all for the patch then.

	--david
