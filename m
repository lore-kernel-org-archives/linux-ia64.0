From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Wed, 29 Jun 2005 20:22:27 +0000
Subject: RE: Xen and the Art of Linux/ia64 Virtualization
Message-Id: <516F50407E01324991DD6D07B0531AD54FA22A@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD54FA228@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Forgot to add the diffstat...

> -----Original Message-----
> From: Magenheimer, Dan (HP Labs Fort Collins) 
> Sent: Wednesday, June 29, 2005 2:17 PM
> To: linux-ia64@vger.kernel.org
> Subject: Xen and the Art of Linux/ia64 Virtualization

 arch/ia64/Kconfig             |    4 ++++
 arch/ia64/Makefile            |    6 ++++++
 arch/ia64/hp/sim/Makefile     |    2 ++
 arch/ia64/ia32/ia32_signal.c  |   12 ++++++++++++
 arch/ia64/ia32/ia32_support.c |    8 ++++++++
 arch/ia64/kernel/entry.S      |   26 ++++++++++++++++++++++++++
 arch/ia64/kernel/head.S       |    4 ++++
 arch/ia64/kernel/irq_ia64.c   |   12 ++++++++++++
 arch/ia64/kernel/pal.S        |   10 +++++++++-
 arch/ia64/kernel/setup.c      |   12 ++++++++++++
 drivers/Makefile              |    1 +
 drivers/acpi/motherboard.c    |    3 +++
 include/asm-ia64/delay.h      |    5 +++++
 include/asm-ia64/ia32.h       |    4 ++++
 include/asm-ia64/processor.h  |   19 +++++++++++++++++++
 include/asm-ia64/system.h     |    4 ++++
