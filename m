From: Nelson Escobar <nelson@myri.com>
Date: Wed, 06 Sep 2000 19:29:19 +0000
Subject: [Linux-ia64] 64 bit PCI DMA transfers?
Message-Id: <marc-linux-ia64-105590678205458@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Do 64 bit PCI DMA transfers work in the test7 kernel yet?

Doing 64 bit PCI DMA transfers to memory less than 2 gigs works
fine.  When I use 4 gigs of memory, the physical address of the last 2
gigs seems to be 0x100000000 - 0x17fffffff.  When I try doing PCI DMA
transfers into this area, everything starts going wrong.

Is this a problem with the kernel?  Or is it a problem with my driver? or
both?

Nelson Escobar
nelson@myri.com




