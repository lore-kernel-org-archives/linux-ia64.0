From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 23 Jan 2015 02:11:47 +0000
Subject: Re: [PATCH v2 23/30] PCI/mvebu: Use pci_common_init_dev() to simplify code
Message-Id: <54C1ADE3.9060606@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1421800225-26230-1-git-send-email-wangyijing@huawei.com> <1421800225-26230-24-git-send-email-wangyijing@huawei.com> <20150122184000.63ba06bb@free-electrons.com>
In-Reply-To: <20150122184000.63ba06bb@free-electrons.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Lior Amsalem <alior@marvell.com>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, Nadav Haklai <nadavh@marvell.com>, =?ISO-8859-1?Q?Gregory_Cl=E9ment?= <gregory.clement@free-electrons.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-m68k@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@linux.intel.com>, linux-alpha@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

On 2015/1/23 1:40, Thomas Petazzoni wrote:
> Dear Yijing Wang,
> 
> On Wed, 21 Jan 2015 08:30:18 +0800, Yijing Wang wrote:
>> Mvebu_pcie_scan_bus() is not necessary, we could use
>> pci_common_init_dev() instead of pci_common_init(),
>> and pass the device pointer as the parent. Then
>> pci_scan_root_bus() will be called to scan the pci busses.
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>> CC: Jason Cooper <jason@lakedaemon.net>
> 
> While I'm fine with the change to pci_common_init_dev(), I am not so
> sure about the removal of mvebu_pcie_scan_bus(). I vaguely remember
> that we intentionally did not use the default function for a specific
> reason. Of course, this was a long time ago, and I don't remember the
> reason. I would have to take a bit of time to 1/ review the archives of
> the discussion surrounding the pcie-mvebu driver, and 2/ test your
> patch to validate it works fine on HW.

Hi Thomas, Thanks for your comments and help to test :)

> 
> Thanks!
> 
> Thomas
> 


-- 
Thanks!
Yijing

