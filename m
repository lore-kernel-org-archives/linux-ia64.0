From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Wed, 02 May 2001 20:26:11 +0000
Subject: RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
Message-Id: <marc-linux-ia64-105590693005518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005516@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005516@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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


