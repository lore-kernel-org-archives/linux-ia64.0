From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 21 Sep 2004 01:41:40 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface
Message-Id: <1095730900.8780.76.camel@mythbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com>
	 <200409201812.45933.dtor_core@ameritech.net>
	 <1095727925.8780.58.camel@mythbox>
	 <200409202020.05776.dtor_core@ameritech.net>
In-Reply-To: <200409202020.05776.dtor_core@ameritech.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Torokhov <dtor_core@ameritech.net>
Cc: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, 2004-09-20 at 20:20 -0500, Dmitry Torokhov wrote:
> On Monday 20 September 2004 07:52 pm, Alex Williamson wrote:
> > On Mon, 2004-09-20 at 18:12 -0500, Dmitry Torokhov wrote: 
> > > 
> > > Hi Anil,
> > > 
> > > I obviously failed to deliver my idea :) I meant that I would like add eject
> > > attribute (along with maybe status, hid and some others) to kobjects in
> > > /sys/firmware/acpi tree.
> > > 
> > 
> > Dmitry,
> > 
> >    See the patch I just posted to acpi-devel and lkml (Subject:
> > [PATCH/RFC] exposing ACPI objects in sysfs).  It exposes acpi objects as
> > you describe.   Something simple like:
> > 
> >  # cat /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/_EJ0
> > 
> > Will call the _EJ0 method on the ACPI device.  You can evaluate eject
> > dependencies using the _EJD method.
> > 
> > 	Alex
> > 
> 
> Alex,
> 
> While I think that your patch is very important and should be included (maybe
> if not as is if somebody has some objections but in some other form) I see it
> more like developer's tool. I imagined status, HID, eject etc. attributes to
> be sanitized interface to kernel's data, not necessarily causing re-evaluation.
> 

Dmitry,

   I imagined the sanitized interfaces would be provided via a userspace
library, similar to how lspci provides a clean interface to all of the
PCI data.  An "lsacpi" tool could extract the information into something
more like you suggest.  If you have objects exposed as human
readable/writable files, I think you'll quickly end up with a _STA
driver, _HID driver, _CID driver, _ADR driver, _UID driver, _EJx driver,
etc, etc, etc...  I don't think we want that kind of bloat in the kernel
(that's what userspace is for ;^).  Providing a solid, direct interface
to ACPI methods in the kernel seems like the most flexible, powerful
interface IMHO.  Thanks,

	Alex

> So it could be like this:
> 
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/status
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/removable
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/lockable
> ..
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/eject
> 
> And your raw access to the ACPI methods could reside under raw:
> 
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_STA
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_RNV
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_LCK
> ..
> /sys/firmware/acpi/namespace/ACPI/_SB/LSB0/raw/_EJ0


