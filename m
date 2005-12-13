From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Dec 2005 20:27:26 +0000
Subject: Re: [PATCH]: Prevent sn2 ptc code from executing on all ia64 subarches
Message-Id: <200512131327.26350.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20051121180016.24224.2378.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 13 December 2005 11:26 am, Prarit Bhargava wrote:
> OTOH the moment they change the initcall sequence we would
> have to change our machine vector interfaces.  And AFAICT no
> one is happy with the 7 levels of init (everything from too
> granular to not granular enough).

Whoa, hold on a minute.  Let's back up.

Most of the uses of ia64_platform_is() are really just hacks
to bind drivers to devices that only exist on SN2:

  arch/ia64/sn/kernel/tiocx.c          tiocx_init()
  arch/ia64/sn/kernel/xp_main.c        xp_init()
  arch/ia64/sn/kernel/xpc_main.c       xpc_init()
  arch/ia64/sn/kernel/xpnet.c          xpnet_init()
  arch/ia64/sn/kernel/sn2/sn_hwperf.c  sn_hwperf_misc_register_init()
  drivers/char/mbcs.c                  mbcs_init()
  drivers/char/mmtimer.c               mmtimer_init()
  drivers/char/snsc.c                  scdrv_init()
  drivers/pci/hotplug/sgi_hotplug.c    sn_pci_hotplug_init()
  drivers/serial/sn_console.c          sn_sal_module_init()
  drivers/sn/ioc4.c                    ioc4_init()

It's totally backwards to limit driver binding by using
ia64_platform_is().

You ought to just describe this hardware in the ACPI namespace
and use acpi_bus_register_driver() to bind the drivers.

Then you can register the drivers on all platforms, but the .add()
function (and hence, the rest of the driver) will only be called
when the hardware is actually present.  So you don't need any
platform-qualified initcalls.
