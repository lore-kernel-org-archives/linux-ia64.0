From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 27 Feb 2015 00:56:34 +0000
Subject: Re: [PATCH v4 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <54EFC0C2.3040000@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424938344-4017-1-git-send-email-wangyijing@huawei.com> <20150226235732.GF25765@google.com>
In-Reply-To: <20150226235732.GF25765@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On 2015/2/27 7:57, Bjorn Helgaas wrote:
> On Thu, Feb 26, 2015 at 04:11:54PM +0800, Yijing Wang wrote:
>> v3->v4:
>> 	Fix the rebase issue.
> 
> This did apply on v4.0-rc1, but with many whitespace complaints:
> 
>   Importing patch "pci-pass-pci-domain-number" ... <stdin>:29: trailing whitespace.
> 	  bus = pci_scan_root_bus(NULL, 
>   <stdin>:44: trailing whitespace.
>       bus = pci_scan_bus_legacy(PCI_DOMBUS(hose->index, 0), 
>   <stdin>:59: trailing whitespace.
>       pbus = pci_create_root_bus(NULL, PCI_DOMBUS(domain, bus), 
>   <stdin>:74: trailing whitespace.
>       bus = pci_scan_root_bus(NULL, 
>   <stdin>:75: trailing whitespace.
> 	      PCI_DOMBUS(controller->segment, busnum), 
>   warning: squelched 15 whitespace errors
>   warning: 20 lines add whitespace errors.
>   done
>   Importing patch "pci-introduce" ... done
>   Importing patch "pci-separate-pci_host_bridge" ... <stdin>:50: trailing whitespace.
>       dev_set_name(&host->dev, "pci%04x:%02x", host->domain, 
>   <stdin>:181: trailing whitespace.
>       dev_set_name(&b->dev, "%04x:%02x", bridge->domain, 
>   <stdin>:225: trailing whitespace.
>       
>   warning: 3 lines add whitespace errors.
> 
> I'll fix them myself this time because I want to make progress on this and
> I need something to do on the plane tomorrow, but please try to fix them
> yourself in the future.
>

I will fix them in the local, thanks!


> Bjorn
> 
> .
> 


-- 
Thanks!
Yijing

