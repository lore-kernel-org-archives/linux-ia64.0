From: "Miller, Mike (OS Dev)" <Mike.Miller@hp.com>
Date: Thu, 26 Jan 2006 17:14:22 +0000
Subject: Problems with MSI-X on ia64
Message-Id: <D4CFB69C345C394284E4B78B876C1CF10B848090@cceexc23.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-ia64@vger.kernel.org

Hello,
Has anyone tested MSI-X on ia64 based platforms? We're using a 2.6.9
variant and a cciss driver with MSI/MSI-X support. The kernel has MSI
enabled. On ia64 the MSI-X table is all zeroes. On Intel x86_64
platforms the table contains valid data and everything works as
expected.

If I understand how this works the Linux kernel is supposed to program
up the table based on the HW platform. I can't find anything in the ia64
code that does this. For x86_64 and i386 it looks like the magic address
is 

	#define APIC_DEFAULT_BASE	0xfee00000

Anybody know why this isn't defined for ia64? Any answers, input, or
flames are appreciated.

Thanks,
mikem
