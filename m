From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 24 Jan 2004 06:06:58 +0000
Subject: Re: [PATCH] 2.6.1 enable PIOW/DMAR relaxed ordering on ZX1
Message-Id: <16402.2946.80534.644026@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123024302.GD24857@cup.hp.com>
In-Reply-To: <20040123024302.GD24857@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 Jan 2004 18:43:02 -0800, Grant Grundler <iod00d@hp.com> said:

  Grant> Tony, David, I lied. Apologies. I thought I had sent this
  Grant> patch before but was just confused by the change in my local
  Grant> bk tree.  I had the patch sitting there since September. :^(

  Grant> This enables DMA Reads to bypass PIO Writes for all PCI/PCI-X
  Grant> devices.  On older RHAS (2.1 orig), this improved netperf UDP
  Grant> Stream by ~10%.  Testing on kernel.org 2.4 kernels showed
  Grant> only ~3-5% improvement.  I suspect because of improvements to
  Grant> tg3 driver.

  Grant> diff is against http://lia64.bkbits.net/linux-ia64-2.6/

I'm not sure Tony's tree is ready for prime-time yet.  Could you
please diff against my tree instead (linux-ia64-2.5)?  I'd have merged
the patch by hand, but the context in the patch you posted doesn't
look like anything that appears in the current sba_iommu.c.

Thanks,

	--david
