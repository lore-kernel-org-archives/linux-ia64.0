From: Troy Heber <troy.heber@hp.com>
Date: Fri, 18 Aug 2006 13:55:16 +0000
Subject: Re: [Fastboot] [patch 3/5] git-ia64 versus genirq
Message-Id: <20060818135515.GA25785@pc.troyhebe>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 08/18/06 08:48, Zou, Nanhai wrote:
> Hi Horms,
> 	I have little knowledge of the code inside CONFIG_IA64_HP_ZX1....
> I think it stop's IOMMU controller on some HP boxes.

Yes, the code is designed to shutdown the IOMMU. The problem we're
seeing is if there are sill in-flight DMA transfers happening when we
shutdown the IOMMU an MCA will occur.

Ring now we're working on a different approach, rather than shutting
down the IOMMU completely, we're going to try to update all of the
valid pdir entries to point to a single pre-alloced page. This should
safely control all of devices with out having to shutdown the IOMMU.

> Aziz told me it is necessary to have this code to start up the second kernel.

I haven't had a chance to speak with Khalid about this approach. I'm
hoping to catch him today.

Troy
