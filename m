From: Mike Smith <msmith@freebsd.org>
Date: Wed, 02 May 2001 23:43:10 +0000
Subject: Re: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
Message-Id: <marc-linux-ia64-105590693005520@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005516@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005516@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's not actually clear from the conversation so far what exactly Matt is 
after.  I get the impression, however, that what he wants to do is 
synthesise an _HID/_UID pair, which is not quite what's being discussed 
here.

If that's the case, typically _HID is the 32-bit vendor/device ID of the 
controller, and _UID is the instance count for the given _HID, eg. the 
first controller has a _UID of 0, the second has a _UID of 1, etc.

> In general a PCI device does not need to have _HID or _UID, because _ADR is
> used for that purpose. If a PCI device happens to be on a root PCI bus, it
> has _HID and _UID as well. So the bus number is avaialble from _BBN on the
> bus, assuming that the OS does not change the PCI bus number.

This isn't entirely correct either.

> -----Original Message-----
> From: Lee, Jung-Ik 
> Sent: Wednesday, May 02, 2001 2:02 PM
> To: Nakajima, Jun; 'Matt_Domsch@Dell.com';
> acpi@phobos.fachschaften.tu-muenchen.de
> Cc: linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
> 
> 
> Even with ACPI namespace, {_HID, _UID} pair does not tell the path of a
> device in a given topology, and can not produce a PCI bus number(vice
> versa).
> _ADR of PCI device does not provide bus number either. It's just dev +func.
>
> So to get PCI bus number of a given PCI bus:
> 1. you can use _BBN of the device, but this works only on root pci bridges.
> I personally want to see all PCI bridges have _BBN method for OSPM's
> convenience, but ACPI spec does not require it for non-roots.

This is because ACPI assumes that you have a functional bus architecture. 
The created bus instance should know its bus number, either from _BBN or 
from querying the bridge's secondary bus number register, so as a device 
you just query your parent for its bus number.

Because Matt's tool is running in userspace, however, this may not be so 
easy to achieve.

> Thus, there seems to be no perfect solutions here... to get pci bus number
> from acpi name space alone.

That's basically correct; you can't do this.

-- 
... every activity meets with opposition, everyone who acts has his
rivals and unfortunately opponents also.  But not because people want
to be opponents, rather because the tasks and relationships force
people to take different points of view.  [Dr. Fritz Todt]
           V I C T O R Y   N O T   V E N G E A N C E



