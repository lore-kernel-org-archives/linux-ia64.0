From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 03 Mar 2015 02:52:22 +0000
Subject: Re: [PATCH v4 13/30] PCI: Introduce new scan function pci_scan_root_bridge()
Message-Id: <20150303025222.GG11978@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com>
 <1424938344-4017-14-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1424938344-4017-14-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, Feb 26, 2015 at 04:12:07PM +0800, Yijing Wang wrote:
> Introduce new scan function pci_scan_root_bridge() to
> support host bridge drivers that need to provide platform
> own pci_host_bridge_ops.
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/probe.c |   21 +++++++++++++++++++++
>  include/linux/pci.h |    3 +++
>  2 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index 8cec6ab..b5f9ca4 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -2063,6 +2063,27 @@ static struct pci_bus *__pci_scan_root_bus(
>  	return b;
>  }
>  
> +struct pci_host_bridge *pci_scan_root_bridge(struct device *parent,
> +		u32 db, struct pci_ops *ops, void *sysdata,
> +		struct list_head *resources, struct pci_host_bridge_ops *phb_ops)

I prefer "host bridge" over "root bridge" because that's the terminology
used by the PCI specs.
