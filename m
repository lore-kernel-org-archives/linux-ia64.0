From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 04 Mar 2010 17:05:41 +0000
Subject: RE: Problem with IDE drive in IA64 system
Message-Id: <987664A83D2D224EAE907B061CE93D53127328A4@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B8F7AE2.6050007@gmx.de>
In-Reply-To: <4B8F7AE2.6050007@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Now a function called pci_get_legacy_irq_device sets the IRQ to 34

I can't see that in current Linus tree ... so this area still seems
to be changing.  I did find:

  pci_get_legacy_ide_irq()

in arch/ia64/include/asm/pci.h  that returns ias_irq_to_vector(14) (or
15 for channel 1).  But this seems to be very old code (2007 according
to git blame).  Perhaps something was put in around .30 and taken out
again???

Can you try building the current Linus tree?

-Tony

