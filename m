From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 20 Sep 2004 19:24:04 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <20040920122404.B15677@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920093532.D14208@unix-os.sc.intel.com> <200409201333.42857.dtor_core@ameritech.net>
In-Reply-To: <200409201333.42857.dtor_core@ameritech.net>; from dtor_core@ameritech.net on Mon, Sep 20, 2004 at 01:33:42PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Torokhov <dtor_core@ameritech.net>
Cc: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Sep 20, 2004 at 01:33:42PM -0500, Dmitry Torokhov wrote:
> On Monday 20 September 2004 11:35 am, Keshavamurthy Anil S wrote:
> > This patch support /sys/firmware/acpi/eject interface where in 
> > the ACPI device say "LSB0" can be ejected by echoing "\_SB.LSB0" > 
> > /sys/firmware/acpi/eject
> > 
> 
> I wonder if eject should be an attribute of an individual device and visible
> only when device can be ejected. Reading from it could show eject level
> (_EJ0/_EJ3 etc).
Hi Dmitry,
	Today there is really no sysfs representation of acpi devices apart from
the acpi namespace representation. Evaluating acpi namespaces's _EJ0 method won't help,
as we need acpi device and all its child devices to be removed as part of the eject.

Also for there is no 1:1 maping of acpi devices to pci devices to consider eject to be
part of the pci devices.

Hence the best solution for now is to echo ACPI full path name of the device to be
ejected onto the eject file and the code will make sure that the device supports _EJx method before actuall removing the device.

thanks,
Anil
> 
> -- 
> Dmitry
