From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 19:12:49 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16442.20657.802164.952563@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

SGI badly wants the 64-bit DMA fix to be in your tree...

Thanks!

	--david

 arch/ia64/sn/io/machvec/pci_dma.c |   72 +++++++++++++++++---------------------
 include/asm-ia64/tlb.h            |    1 
 2 files changed, 34 insertions(+), 39 deletions(-)

through these ChangeSets:

<jeremy@sgi.com> (04/02/20 1.1661)
   [PATCH] ia64: Fix 64 bit DMA mapping problem with PCI cards on SN2
   
   PCI cards were forced to 32 bit addresses.  There is significant
   extra overhead to DMA setup with 32 bit, and it is fairly easy to
   run out of mapping resources.
   
   This patch reenables 64 bit DMA mapping for PCI cards.

<akpm@osdl.org> (04/02/20 1.1660)
   [PATCH] ia64: fix sched.c compile warning
   

