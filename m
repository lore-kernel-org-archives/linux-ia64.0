From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Wed, 02 May 2001 23:23:55 +0000
Subject: RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
Message-Id: <marc-linux-ia64-105590693005519@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005516@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005516@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In general a PCI device does not need to have _HID or _UID, because _ADR is
used for that purpose. If a PCI device happens to be on a root PCI bus, it
has _HID and _UID as well. So the bus number is avaialble from _BBN on the
bus, assuming that the OS does not change the PCI bus number.

So as long as you are interested in _HID and _UID of a PCI device, you
should be able to assume _BBN, thus, PCI bus number.

Jun 

-----Original Message-----
From: Lee, Jung-Ik 
Sent: Wednesday, May 02, 2001 2:02 PM
To: Nakajima, Jun; 'Matt_Domsch@Dell.com';
acpi@phobos.fachschaften.tu-muenchen.de
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number


Even with ACPI namespace, {_HID, _UID} pair does not tell the path of a
device in a given topology, and can not produce a PCI bus number(vice
versa).
_ADR of PCI device does not provide bus number either. It's just dev +func.
 
So to get PCI bus number of a given PCI bus:
1. you can use _BBN of the device, but this works only on root pci bridges.
I personally want to see all PCI bridges have _BBN method for OSPM's
convenience, but ACPI spec does not require it for non-roots.
2. you can enumerate pci bus from root pci bridges, following PCI std df
enum scheme, and access pci config space of pci bridges to get BIOS set bus
numbers. (But note that bus numbers set by BIOS do not necessarily match to
what OSes assign. For reasons OSes can assign bus numbers different from
BIOS's. So, PCI numbers from pci config space at EFI boot manager time, it's
not always the same as OSes enumerates) Afaik, linux does not alter bus
numbers set by BIOS yet, but someday...)

Thus, there seems to be no perfect solutions here... to get pci bus number
from acpi name space alone.

J.I.


-----Original Message-----
From: Nakajima, Jun [mailto:jun.nakajima@intel.com]
Sent: Wednesday, May 02, 2001 1:26 PM
To: 'Matt_Domsch@Dell.com'; acpi@phobos.fachschaften.tu-muenchen.de
Cc: linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number


Not all PCI devices appear in the ACPI namespace. If a PCI device shows up
in the ACPI namespace, it should have _ADR, which basically is its PCI bus,
device, and function number. Then you can tell the _HID and _UID associated
with that device. Hope this helps.

Jun

-----Original Message-----
From: Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
Sent: Wednesday, May 02, 2001 12:34 PM
To: acpi@phobos.fachschaften.tu-muenchen.de
Cc: linux-ia64@linuxia64.org
Subject: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number


I'm working on a user-space application to add a Linux entry to the IA-64
EFI Boot Manager.  One component of this entry is the ACPI _HID and _UID
fields, which correspond to a PCI bus number (in Linux kernel terms).  I
know the PCI bus number, device, and function, for a given controller.  What
I don't have is the ACPI _HID and _UID fields that match the PCI bus number.
Any thoughts on how I can get them?

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


