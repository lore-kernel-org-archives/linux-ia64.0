From: "Ahna, Christopher J" <christopher.j.ahna@intel.com>
Date: Thu, 30 Nov 2000 16:21:20 +0000
Subject: RE: [Linux-ia64] NIC not working after ACPI PXE boot - solution!
Message-Id: <marc-linux-ia64-105590678205778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205777@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205777@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,

This very same fix was developed here at Intel and integrated into the
BigSur BIOS a few weeks back.  The next released version of BigSur FW will
include this fix.  I believe this fix will get pushed into standard releases
of EFI, so all EFI based FW should get this problem solved in time.  This is
pretty much a bug in EFI, so I don't think a workaround needs to go into the
kernel permanently.  Thanks,

Chris

-----Original Message-----
From: Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
Sent: Thursday, November 30, 2000 8:02 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] NIC not working after ACPI PXE boot - solution!


Some engineers here at Dell have developed a solution to the issue where the
on-board NIC is unresponsive to Linux if first EFI tried to use it.  We're
working through the licensing issues to make the code GPL, but until then, I
can provide a simple functional description, and if someone wished to write
code and add it to the kernel, great! :)

The basic steps are:
use BS->LocateHandle(SimpleNetworkProtocol) to get the number of NICs in the
system.
for each handle returned:
	use BS->HandleProtocol() get EFI_SIMPLE_NETWORK->Mode->State.
	if State != shutdown
		call EFI_SIMPLE_NETWORK->Shutdown() on the NIC
		call EFI_SIMPLE_NETWORK->Stop() on the NIC

This obviously needs to be done prior to loading network drivers, either in
the kernel or in eli/lilo.

Thanks,
Matt Domsch
Dell Enterprise Systems Group
Linux Development Team




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


