From: Matt_Domsch@Dell.com
Date: Thu, 03 May 2001 04:26:41 +0000
Subject: RE: [Acpi] RE: [Linux-ia64] translating ACPI _HID & _UID to PCI b
Message-Id: <marc-linux-ia64-105590693005525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005524@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005524@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

