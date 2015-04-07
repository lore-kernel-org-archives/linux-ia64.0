From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 07 Apr 2015 22:42:43 +0000
Subject: Re: [PATCH v9 08/30] PCI: Update pci_host_bridge bus resource
Message-Id: <20150407224243.GL10892@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428053164-28277-1-git-send-email-wangyijing@huawei.com>
 <1428053164-28277-10-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1428053164-28277-10-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing0307@gmail.com>

On Fri, Apr 03, 2015 at 05:25:42PM +0800, Yijing Wang wrote:
> From: Yijing Wang <wangyijing0307@gmail.com>
> 
> Sometimes, the bus resource start number is not equal to
> root bus number. For example, in pci_scan_bus(), we always
> add the default bus resource which start bus number is 0,
> but the root bus number callers given may != 0, so
> we need to update pci_host_bridge bus resource, because we
> would check whether host bridge bus resoruce is confict
> in later patch.

It's true that pci_scan_bus() always inserts [bus 00-ff].  But I think
that's completely bogus.  The caller of pci_scan_bus() supplies a root bus
number X.  Any bus numbers below X are useless as far as this host bridge
is concerned, and it's pointless to include them in the range inserted by
pci_scan_bus().

I think we'd be better off if we forced every pci_scan_bus() caller to
supply a real non-overlapping bus number range.  We probably can't do that
easily because the arch knows the beginning bus number, but some don't know
how to figure out the ending bus number.

Do we have a per-domain structure that tracks the bus numbers in use in the
domain?  It seems like if we had one, we could use that to approximate the
end.  For example, if the arch scans three root buses, at bus 00, bus 40,
and bus 80, we could start with the first one at [bus 00-ff], and when we
scan the one at bus 40, we could either report a conflict (if the bus 00
tree included a bus 40) or reduce the first range to [bus 00-3f].

> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/pci/host-bridge.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/pci/host-bridge.c b/drivers/pci/host-bridge.c
> index ecc1a7c..1a9834b 100644
> --- a/drivers/pci/host-bridge.c
> +++ b/drivers/pci/host-bridge.c
> @@ -26,8 +26,11 @@ static void pci_host_update_busn_res(
>  	struct resource_entry *window;
>  
>  	resource_list_for_each_entry(window, resources)
> -		if (window->res->flags & IORESOURCE_BUS)
> +		if (window->res->flags & IORESOURCE_BUS) {
> +			if (bus > window->res->start)
> +				window->res->start = bus;

I see what you're trying to do here, but I think this is the wrong place to
do it.  I'd rather figure out a way to insert something other than
busn_resource in pci_scan_bus().  That probably means we need to
dynamically allocate a new busn_res struct.

>  			return;
> +		}
>  
>  	pr_info(
>  	 "No busn resource found for pci%04x:%02x, will use [bus %02x-ff]\n",
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
