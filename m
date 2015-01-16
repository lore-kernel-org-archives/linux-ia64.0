From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Jan 2015 09:44:29 +0000
Subject: Re: [PATCH 27/28] PCI: Remove platform specific pci_domain_nr()
Message-Id: <1561857.t9qV46uRjC@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <1421372666-12288-28-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-28-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Geert Uytterhoeven <geert@linux-m68k.org>

On Friday 16 January 2015 09:44:25 Yijing Wang wrote:
> 
> +int pci_domain_nr(struct pci_bus *bus)
> +{
> +       struct pci_host_bridge *host = find_pci_host_bridge(bus);
> +
> +       return host->domain;
> +}
> +EXPORT_SYMBOL_GPL(pci_domain_nr);
> +

Since most of the existing functions are exported as EXPORT_SYMBOL
rather than EXPORT_SYMBOL_GPL, I think the new version should do
the same.

	Arnd
