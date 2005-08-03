From: Mark Maule <maule@sgi.com>
Date: Wed, 03 Aug 2005 21:05:22 +0000
Subject: [PATCH 2.6.13 0/4] altix: TIOCE pci express provider
Message-Id: <20050803210522.785.542.49201@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patchset provides new hardware support for the SGI TIOCE pci express chip,
implemented as an altix SN PCI "provider".

This patchset was generated against Tony Luck's test-2.6 tree on 8/3 plus
the following recently submitted patch by Colin Ngam:

	http://marc.theaimsgroup.com/?l=linux-ia64&m2310130923852&w=2

Mark

[1/4] altix-rename-pcibr-error.patch
	Cosmetic rename of SN asic error handler #define

[2/4] altix-force-interrupt.patch
	Abstract force_interrupt() to use an SN PCI provider hook rather than
	hard-coding pcibr.

[3/4] altix-sn_dma_flush-hugewindow.patch
	Add support for the TIO huge window to sn_dma_flush()
	
[4/4] altix-tioce-provider.patch
	New SN PCI provider for the TIO:CE asic
