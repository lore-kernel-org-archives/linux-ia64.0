From: dveloper@bellsouth.net
Date: Thu, 03 May 2001 04:39:48 +0000
Subject: RE: [Acpi] RE: [Linux-ia64] translating ACPI _HID & _UID to PCI bus number
Message-Id: <marc-linux-ia64-105590693005526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005524@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005524@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

_UID is no matter, whatever numbers you like. The _HID, _UID pair should
make your device unique if you have to assign same _HID for several of them.
You may omit _UID at all if there is only one _HID of it's kind in the DSDT.

Cheers

-Vit

-----Original Message-----
From: Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
Sent: Thursday, May 03, 2001 12:27 AM
To: dveloper@bellsouth.net; jung-ik.lee@intel.com;
jun.nakajima@intel.com; acpi@phobos.fachschaften.tu-muenchen.de
Cc: linux-ia64@linuxia64.org
Subject: RE: [Acpi] RE: [Linux-ia64] translating ACPI _HID & _UID to PCI
bus number


> _HID for the host (or hosts in case of peer bus
> architecture) is
> "PNP0A03". _UID is needed only if there are several devices
> with the same
> _HID, serial ports COM A and B, for instance, to distinguish
> them or PEER
> BUS architecture again.

Ahh, of course, _HID = EISAID("PNP0A03") = a0341d0.  That helps.
Now for the _UID...

-Matt


