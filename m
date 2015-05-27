From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 27 May 2015 19:31:49 +0000
Subject: Re: [PATCH 2/2] PCI: pciehp: Convert pciehp to be builtin only, not modular
Message-Id: <20150527193149.GD10210@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130725175242.6006.56007.stgit@bhelgaas-glaptop>
 <20130725175727.6006.98109.stgit@bhelgaas-glaptop>
 <CAE9FiQU9k6m-5bM5ZfFUZxW3H7_v4aOtaK66pa7iV0Zb-J86jw@mail.gmail.com>
 <CAE9FiQXq59tSBM0SQ4OToXydZrRC3yukALmWEb6K9xpCGbdUhg@mail.gmail.com>
In-Reply-To: <CAE9FiQXq59tSBM0SQ4OToXydZrRC3yukALmWEb6K9xpCGbdUhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yinghai Lu <yinghai@kernel.org>
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

[updated Rafael's email addr; not sure if sisk.pl still works or not]

On Wed, May 27, 2015 at 11:31:21AM -0700, Yinghai Lu wrote:
> On Fri, Jul 26, 2013 at 5:43 AM, Yinghai Lu <yinghai@kernel.org> wrote:
> > On Thu, Jul 25, 2013 at 10:57 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> >> Convert pciehp to be builtin only, with no module option.
> >>
> >> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> >> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> >> ---
> >>  drivers/pci/pcie/Kconfig |    5 +----
> >>  1 file changed, 1 insertion(+), 4 deletions(-)
> >>
> >> diff --git a/drivers/pci/pcie/Kconfig b/drivers/pci/pcie/Kconfig
> >> index 569f82f..3b94cfc 100644
> >> --- a/drivers/pci/pcie/Kconfig
> >> +++ b/drivers/pci/pcie/Kconfig
> >> @@ -14,15 +14,12 @@ config PCIEPORTBUS
> >>  # Include service Kconfig here
> >>  #
> >>  config HOTPLUG_PCI_PCIE
> >> -       tristate "PCI Express Hotplug driver"
> >> +       bool "PCI Express Hotplug driver"
> >>         depends on HOTPLUG_PCI && PCIEPORTBUS
> >>         help
> >>           Say Y here if you have a motherboard that supports PCI Express Native
> >>           Hotplug
> >>
> >> -         To compile this driver as a module, choose M here: the
> >> -         module will be called pciehp.
> >> -
> >>           When in doubt, say N.
> >>
> >>  source "drivers/pci/pcie/aer/Kconfig"
> >>
> >
> > Acked-by: Yinghai Lu <yinghai@kernel.org>
> 
> Hi Bjorn,
> 
> Looks like we lose the option to disable pciehp after we make it as built-in.
> 
> Before acpiphp and pciehp could be compiled as modules, and user could
> blacklist to disable them.
> 
> Now they are all built-in, but only acpiphp has acpiphp.disable to
> disable acpiphp.
> we don't have pciehp.disable yet.
> 
> Do you think if we should add pciehp.disable ?

Did you find a situation that would require pciehp.disable?  I hesitate to
add it because if there's a problem and pciehp.disable fixes it, people
tend to think the solution is "boot with pciehp.disable."  But the *real*
solution is to fix whatever is broken in the kernel, so no parameter is
needed at all.

> BTW we don't have any description for acpiphp.disable anywhere.

True.  I'll give you my opinion; Rafael may have a different one.

I don't know whether it's a good idea to add a description or not, for the
same reason as above.  I think we should actively discourage people from
using kernel parameters, except for debugging purposes and for some legacy
issues where there's no way for the kernel to figure things out by itself.
But in my opinion, acpiphp isn't in any of those categories, so I'm content
to have the parameter present but undocumented.  It seems more likely that
we'll hear about issues then, and we might be able to do something about
them.

Bjorn
