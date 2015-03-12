From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 12 Mar 2015 19:56:51 +0000
Subject: Re: [PATCH v6 10/30] PCI: Introduce pci_host_bridge_list to manage host bridges
Message-Id: <20150312195651.GD7346@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
 <1425868467-9667-11-git-send-email-wangyijing@huawei.com>
 <20150312025537.GD10949@google.com>
 <55018E90.9030301@huawei.com>
In-Reply-To: <55018E90.9030301@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, Mar 12, 2015 at 09:03:12PM +0800, Yijing Wang wrote:
> On 2015/3/12 10:55, Bjorn Helgaas wrote:
> > On Mon, Mar 09, 2015 at 10:34:07AM +0800, Yijing Wang wrote:
> >> Introduce pci_host_bridge_list to manage pci host
> >> bridges in system, so we could detect whether
> >> the host in domain:bus is alreay registered.
> >> Then we could remove bus alreay exist test in
> >> __pci_create_root_bus().
> > 
> > It's a nice idea to move this test into the core.  While you're at it, why
> > don't you check for any overlap with the bus ranges of existing host
> > bridges?  For example, if we're trying to create a new host bridge to
> > [bus 40-7f], it should conflict with existing bridges to [bus 00-7f]
> > as well as to [bus 40-ff].  I think your current patch will detect the
> > latter conflict but not the former.
> 
> Now pci host bridge may only know its start bus number, like acpi _BBN provided,
> but does not limit the end bus number, Eg. two pci roots report _BBN 0x0 and 0x80,
> so we have two bus number resource (0, 0xff) and (0x80, 0xff), if we check it strictly,
> some pci scan would fail which currently scan success.

_BBN is not the correct source for the bridge's bus number range.  There's
a comment in acpi_pci_root_add() that explains why:

  * We need both the start and end of the downstream bus range
  * to interpret _CBA (MMCONFIG base address), so it really is
  * supposed to be in _CRS.  If we don't find it there, all we
  * can do is assume [_BBN-0xFF] or [0-0xFF].

A platform SHOULD know the start and and end bus number.  If it doesn't I
think it's the platform's responsibility to carve up the bus number range.
Maybe this can be done by trimming the range of the [bus 00-ff] bridge when
we discover another bridge that leads to bus 80.
