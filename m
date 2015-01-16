From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 16 Jan 2015 09:08:45 +0000
Subject: Re: [PATCH 08/28] PCI: Introduce pci_host_assign_domain_nr() to assign domain
Message-Id: <13182982.DnZJMY2KHL@wuerfel>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421372666-12288-1-git-send-email-wangyijing@huawei.com> <1421372666-12288-9-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1421372666-12288-9-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: Yijing Wang <wangyijing@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, Russell King <linux@arm.linux.org.uk>, Marc Zyngier <marc.zyngier@arm.com>, linux-pci@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-m68k@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>

On Friday 16 January 2015 09:44:06 Yijing Wang wrote:
> Introduce pci_host_assign_domain_nr() to assign domain
> number for pci_host_bridge. Later we will remove
> pci_bus_assign_domain_nr().
> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>

I'm confused: the same code is already part of the PCI tree, but with
Lorenzo Pieralisi listed as the patch author. The code is good,
and I acked it in the past, but one of you is (probably by accident)
misattributing the patch.

Assuming that the patch that is already merged in next is the right
one, I think you should rebase your series on top of

git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git#next

to avoid conflicts like this one.

	Arnd
