From: Mark Maule <maule@sgi.com>
Date: Fri, 05 Aug 2005 21:12:57 +0000
Subject: [PATCH 2.6.13 0/6] altix: TIOCE pci express provider
Message-Id: <20050805211257.5173.72259.50015@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Resending ... first attempts would not pass one of the patches through the
ia64 mail server, so I split it up be smaller hoping that would work better.

This patchset provides new hardware support for the SGI TIOCE pci express chip,
implemented as an altix SN PCI "provider".

This patchset was generated against Tony Luck's test-2.6 tree on 8/3 plus
the following recently submitted patch by Colin Ngam:

	http://marc.theaimsgroup.com/?l=linux-ia64&m2310130923852&w=2

Mark

[1/6] altix-rename-pcibr-error.patch
	Cosmetic rename of SN asic error handler #define

[2/6] altix-force-interrupt.patch
	Abstract force_interrupt() to use an SN PCI provider hook rather than
	hard-coding pcibr.

[3/6] altix-sn_dma_flush-hugewindow.patch
	Add support for the TIO huge window to sn_dma_flush()
	
[4/6] altix-tioce_h.patch
	New tioce.h file

[5/6] altix-tioce_provider_c.patch
	New tioce_provider.c and tioce_provider.h files

[6/6] altix-tioce-enable.patch
	Modify files necessary to enable patches 4/6 and 5/6.
