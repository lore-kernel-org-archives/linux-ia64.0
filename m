From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 16 Apr 2003 23:30:50 +0000
Subject: [Linux-ia64] Re: [PATCH] 2.4.20 sba_iommu bug fix
Message-Id: <marc-linux-ia64-105590723705522@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 31 March 2003 2:51 pm, Alex Williamson wrote:
> 
>    This patch ensures that iopdir updates are visible on the bus
> before we return a DMA mapping.  Without this there is a small
> window where the chipset could fetch an invalid iodpir entry
> from memory.  As Grant mentioned before, we've only seen this
> problem exposed with multiple tulip NICs under load.  Bjorn,
> please apply.  Working on something for 2.5... (more extensive
> updates)  Thanks,

I applied this for 2.4.

