From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 21 Sep 2004 03:02:18 +0000
Subject: RE: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject
Message-Id: <1095735738.3920.29.camel@mythbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F84059309EF@pdsmsx403>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F84059309EF@pdsmsx403>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Luming" <luming.yu@intel.com>
Cc: Dmitry Torokhov <dtor_core@ameritech.net>, acpi-devel@lists.sourceforge.net, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>


>   This sounds like a good idea. To call the raw AML methods from
> User space, just need to solve the problem of argument passing.

   Solved, the driver I proposed takes an acpi_object_list for passing
arguments to the methods.  The kernel-userspace interface replaces the
pointers in these structures with offsets into the buffer (userspace
responsibility to pass in offsets, kernel responsibility to pass back
offsets).  I've modified the sysfs bin_file to allow ACPI object files
to have backing store on a per-open basis.  There are special commands
that can be written to the ACPI object files to evaluate attributes of
them.  Perhaps these could include some of the things we're looking for
here.

> But, some AML methods are risky to be called directly from user space,
> Not only because the side effect of its execution, but also because
> it could trigger potential AML method bug or interpreter bug, or even
> architectural defect.  All of these headache is due to the AML method
>  is NOT intended for being used by userspace program.

   I've made an attempt to hide the most obvious dangerous methods, but
undoubtedly, there will be some.  Why are we any more likely to hit an
AML method bug, interpreter bug or architectural bug by having a
userspace interface?  Because we can more easily exercise the code?  It
calls the same code paths a driver could.  The driver I propose for this
task does not require any additionally low-level ACPI functions to be
exported.  I think it's too much complexity in the kernel to abstract
every possible bit of data someone might find useful into kernel
drivers.

   Take a simple case of looking for a device with a specific _HID value
and wanting the _CRS data for it.  The _HID value part is easy, but add
all the smarts to parse the _CRS data into something human readable, and
code bloat gets huge.  Then throw in the problem of parsing vendor data
types, and you'll never get finished.  This is a real example.  The zx1
ia64 chipset can only be discovered through ACPI namespace.  It's
physical address is saved in a vendor resource descriptor.  We currently
have to do some pretty ugly stuff in X to take a reasonable guess a what
chipset we're using.  We need some mechanism to get this data in
userspace, and I don't see an approach better than offloading the
complicated data parsing into userspace.  Adding only the methods needed
to solve a specific problem sounds like a maintainability nightmare.
Thanks,

	Alex

