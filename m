From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Date: Fri, 24 Sep 2004 20:39:12 +0000
Subject: Re: [ACPI] [PATCH] PCI IRQ resource deallocation support [2/3]
Message-Id: <Pine.LNX.4.60.0409242236330.7426@poirot.grange>
List-Id: <linux-ia64.vger.kernel.org>
References: <414FEBDB.2050201@soft.fujitsu.com> <200409210857.59457.bjorn.helgaas@hp.com>
 <4150D458.3050400@jp.fujitsu.com> <20040924.145229.108814142.t-kochi@bq.jp.nec.com>
 <4153BEBA.5030202@jp.fujitsu.com>
In-Reply-To: <4153BEBA.5030202@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, bjorn.helgaas@hp.com, acpi-devel@lists.sourceforge.net, kaneshige.kenji@soft.fujitsu.com, akpm@osdl.org, greg@kroah.com, len.brown@intel.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 24 Sep 2004, Kenji Kaneshige wrote:

> Takayoshi Kochi wrote:
> I'll change my patch to leave dev->irq as it is. And then I'll
> investigate about defining PCI_UNDEFINED_IRQ.

Some platforms (arm, arm26, ppc64) define a macro NO_IRQ:

include/asm-arm/irq.h:#define NO_IRQ        ((unsigned int)(-1))
include/asm-arm26/irq.h:#define NO_IRQ      ((unsigned int)(-1))
include/asm-ppc64/irq.h:#define NO_IRQ      (-1)

Thanks
Guennadi
---
Guennadi Liakhovetski

