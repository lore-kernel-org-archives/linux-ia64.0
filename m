From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 May 2003 23:31:29 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705714@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, some more info: I missed the following boot-time error messages:

PCI: Probing PCI hardware on bus (00:00)
alloc 0x3b0-0x3df from PCI IO for PCI Bus 00:00 failed
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Root Bridge [PCI1] (00:01)
PCI: Probing PCI hardware on bus (00:01)
alloc 0x0-0x0 from PCI IO for PCI Bus 00:01 failed
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
ACPI: PCI Root Bridge [PCI2] (00:02)
PCI: Probing PCI hardware on bus (00:02)
alloc 0x2000-0x2fff from PCI IO for PCI Bus 00:02 failed
alloc 0x0-0x0 from PCI mem for PCI Bus 00:02 failed
alloc 0x0-0x0 from PCI IO for PCI Bus 00:02 failed
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
ACPI: PCI Root Bridge [PCI3] (00:03)
PCI: Probing PCI hardware on bus (00:03)
alloc 0xa0000-0xfffff from PCI mem for PCI Bus 00:03 failed
alloc 0x3b0-0x3df from PCI IO for PCI Bus 00:03 failed

Maybe it isn't a firmware problem, after all.

	--david

