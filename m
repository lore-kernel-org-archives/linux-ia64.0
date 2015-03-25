From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Wed, 25 Mar 2015 16:43:21 +0000
Subject: Re: [PATCH v8 23/30] PCI/mvebu: Use pci_common_init_dev() to simplify code
Message-Id: <20150325174321.4a5bc25d@free-electrons.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1427168064-8657-1-git-send-email-wangyijing@huawei.com>
	<1427168064-8657-24-git-send-email-wangyijing@huawei.com>
	<551277E6.1010307@huawei.com>
In-Reply-To: <551277E6.1010307@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Jason Cooper <jason@lakedaemon.net>, Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

Dear Yijing Wang,

On Wed, 25 Mar 2015 16:55:02 +0800, Yijing Wang wrote:

>    Do you have any comment for this patch ? In this series, pci_bus_add_devices()
> has been ripped out from pci_scan_root_bus(), so I think the pci_scan_root_bus() is
> almost the same as pci_create_root_bus + pci_scan_child_bus(). And in this series,
> we try to unexport pci_create_root_bus(). It's even better if you could help test this changes.

I'm away this week for ELC, but I promise to test you patch series on
mvebu hardware next week.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
