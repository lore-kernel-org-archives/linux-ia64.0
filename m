From: Matt_Domsch@Dell.com
Date: Thu, 30 Nov 2000 16:02:19 +0000
Subject: [Linux-ia64] NIC not working after ACPI PXE boot - solution!
Message-Id: <marc-linux-ia64-105590678205777@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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




