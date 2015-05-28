From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 28 May 2015 22:19:50 +0000
Subject: Re: [PATCH 2/2] PCI: pciehp: Convert pciehp to be builtin only, not modular
Message-Id: <1432851590.4526.4.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130725175242.6006.56007.stgit@bhelgaas-glaptop>
	 <CAE9FiQXq59tSBM0SQ4OToXydZrRC3yukALmWEb6K9xpCGbdUhg@mail.gmail.com>
	 <20150527193149.GD10210@google.com> <4269355.CI4MW738Od@vostro.rjw.lan>
	 <CAE9FiQWDsQxKK3m4_-dSXm8V3xNc4oOtg2UQi=aayeKhLutwQg@mail.gmail.com>
In-Reply-To: <CAE9FiQWDsQxKK3m4_-dSXm8V3xNc4oOtg2UQi=aayeKhLutwQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yinghai Lu <yinghai@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Bjorn Helgaas <bhelgaas@google.com>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-sh@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, 2015-05-28 at 15:08 -0700, Yinghai Lu wrote:
> On Wed, May 27, 2015 at 6:30 PM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > On Wednesday, May 27, 2015 02:31:49 PM Bjorn Helgaas wrote:
> > For debug you can always use pcie_ports=compat and that will disable
> > pciehp too.
> 
> That will disable AER at the same time, right?.

For ppc machines under either our hypervisor or running bare metal with
our EEH-enabled bridges, both generic AER and hotplug code are going to
interfere.

EEH "subsumes" AER, and we have firmware interfaces to do hotplug that
know more than what the generic code can know about (such as on-board
GPIOs that can control PERST, it's not always via the hotplug registers
or hotplug from top-level slots which isn't the same as hotplug from
switch slots on our platforms).

So basically, at this point, we must not have the PCIe port drivers at
all, just just interfere.

We should replace that with the appropriate "hooks" for the platform to
disable selected functions (hotplug and AER) from the generic port
drivers.

Cheers,
Ben.


