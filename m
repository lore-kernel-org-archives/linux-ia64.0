From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Jan 2015 09:14:09 +0000
Subject: Re: [PATCH 09/28] PCI: Separate pci_host_bridge creation out of pci_create_root_bus()
Message-Id: <6955534.AnUg4xpxEu@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <1421372666-12288-10-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-10-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-m68k@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>

On Friday 16 January 2015 09:44:07 Yijing Wang wrote:
> We want to make a generic pci_host_bridge, then we could
> place common PCI infos like domain number in it. Ripping
> out pci_host_bridge creation from pci_create_root_bus()
> make code more better readability. Further more, we could
> use the generic pci_host_bridge to hold host bridge specific
> operations like pcibios_root_bridge_prepare().
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> 

I assume this patch is doing the right thing, but the description
above doesn't really tell me enough to be sure.

This is supposed to be transparent to the callers, right? If
so, please mention it explicitly in the text.

Also you don't explain what the list of host bridges is
used for. Maybe you can split this out into a separate patch
so you have one patch that just moves code from one file
to the other but no functional changes, and a second patch
that exports pci_create_host_bridge and introduces the list,
with an explanation of what it is used for.

	Arnd
