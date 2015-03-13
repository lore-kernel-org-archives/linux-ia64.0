From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 13 Mar 2015 14:48:25 +0000
Subject: Re: [PATCH v6 00/30] Refine PCI scan interfaces and make generic pci host bridge
Message-Id: <CAErSpo7KuchFy0U=80buz4oRKwn-tcwz1Ej9-hBZHg+a-eYCbw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <20150312212306.GH7346@google.com> <20150313113156.GA4739@bart.dudau.co.uk>
In-Reply-To: <20150313113156.GA4739@bart.dudau.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Liviu Dudau <liviu@dudau.co.uk>
Cc: Yijing Wang <wangyijing@huawei.com>, Jiang Liu <jiang.liu@linux.intel.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm <linux-arm-kernel@lists.infradead.org>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Fri, Mar 13, 2015 at 6:31 AM, Liviu Dudau <liviu@dudau.co.uk> wrote:
> On Thu, Mar 12, 2015 at 04:23:06PM -0500, Bjorn Helgaas wrote:
>> On Mon, Mar 09, 2015 at 10:33:57AM +0800, Yijing Wang wrote:
>> > ...
>> > Yijing Wang (29):
>> >   PCI: Rip out pci_bus_add_devices() from pci_scan_bus()
>> >   PCI: Rip out pci_bus_add_devices() from pci_scan_root_bus()
>> >   sparc/PCI: Claim bus resources before pci_bus_add_devices()
>>
>> I put the above patches plus a cleanup patch on my pci/enumeration branch.
>> Please rebase your next revision to that.  If there's anything else
>> non-controversial that we can pull in to chip away at this, let me know.
>
> Hi Bjorn and Yijing,
>
> Sorry for not providing feedback earlier on this series (or any previous ones),
> I'm just crawling out from under a rock of doing graphics drivers :)
>
> The patch ripping out pci_bus_add_devices() from pci_scan_root_bus() misses out
> the users of that function from drivers/pci/host. If Yijing is going to refresh
> the series it is probably worth starting with adding back the call into pcie-xilinx.c
> and pci-versatile.c.

Huh, sure enough, I missed those, too.  Yijing, when you add those,
can you pull my branch, update the patch, and repost it?  That way
you'll keep my changelog and cleanup updates.

Bjorn
