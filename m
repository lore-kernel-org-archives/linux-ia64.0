From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Wed, 08 Aug 2001 09:55:41 +0000
Subject: [Linux-ia64] AGP
Message-Id: <marc-linux-ia64-105590693006009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am wondering to which extent AGP and DRI are supported by Linux-IA64.
So far I have always configured agpgart and DRI into my kernels, but I
keep getting depmod error messages:

depmod: *** Unresolved symbols in /lib/modules/2.4.7fsc/kernel/drivers/char/agp/agpgart.o
depmod: 	agp_vmmap
depmod: 	agp_vmunmap
depmod: 	agp_flush_tlb_all

(I know that fixing this requires only a tiny Makefile patch, but the fact
that this problem exists at least since 2.4.3 makes me feel taht noone
ever tried this out).

On Lion at least, there is no AGP bus anyway. I don't know about Big Sur,
but the option "Enable full AGP RQ (requires Big Sur BIOS 99 or newer)
seems to suggest that Big Sur supports AGP.

My questions:
- Is it correct that AGP/DRI support makes no sense on Lion?
- What about BigSur?

Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




