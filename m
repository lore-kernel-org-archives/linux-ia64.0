From: Alan Mayer <ajm@sgi.com>
Date: Tue, 07 Oct 2003 16:44:49 +0000
Subject: Re: [PATCH] kill two dead headers
Message-Id: <marc-linux-ia64-106554523028139@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451477025244@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451477025244@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is in response to a series of patches from Christoph Hellwig
against the SGI IO infrastructure.  These patches fall into three
categories, but first let me say this:   There is nothing wrong with
what Christoph is trying to do.   The IO infrastructure needs work.
It is also complicated, too complicated.  We at SGI are addressing
the issues that Christoph raises and more.  We also have the resources,
both people and machines, to address these issues effectively.  Our
failure has been the slowness with which we have pushed our code into
2.6.  This is also being addressed.  Now the categories:

1.  It's already been done.  Many of the patches that Christoph submitted
have been taken care of here at SGI, but the code hasn't been pushed
out to 2.6.  Some of Christoph's patches in this category are incomplete.
Some of the code he deleted performs a necessary function and his
patches result in panic's.  Were the patches tested on HW?  What
configurations?  These patches include:

[PATCH] kill two dead headers.
[PATCH] make sn2 devfs-clean.
[PATCH] kill sn_ksyms.c.
[PATCH] kill sn2 inventory stubs.
[PATCH] kill dead code from ml_iograph.c.
[PATCH] kill .hcl entry in hwgfs.
[PATCH] remove CONFIG_PCI ifdefs in SN2 code.
[PATCH] more dead headers.
 [PATCH] kill arc leftovers.
[PATCH] kill machvec_sn1.h.
[PATCH] kill more inventory code.
[PATCH] fix two compiler warnings in SN2 code.

2.  It should be done, but it's not nearly as simple as it appears.  We
have someone assigned to work on it, including issues regarding unobvious
dependence on or by other parts of the code, and requirements of planned,
but unreleased, new hardware.  These things require extensive testing with
various HW configs.

 [PATCH] kill snia_pciio_*
[PATCH] simplify and speedup SN2 dma mapping.
[PATCH] sn_ML_intr.c is a freakin mess.
 [PATCH] simplify SN2 interrupt allocation.
[PATCH] fix the sn_pci_fixup mess.
[PATCH] update arch/ia64/sn/kernel/sn2/Makefile.
[PATCH] avoid a layer of indirection in SN2 pci config space access.
[PATCH] sanitize SN2 pci resource setup.
[PATCH] kill pciio_provider*.
 [PATCH] fix intr_heuristic().

3. Don't care or it's fine to put in.

[PATCH] kill kdba_io.c
[PATCH] kill sn_ksyms.c


It would simplify our lives enormously if none of these patches were applied, with the possible
exception of the last two.  They're pretty much stomping all over work already in progress or
introducing bugs that we don't really have the time or resources to track down and fix.

		--ajm

Lately it occurs to me,
What a long, strange trip it's been.
--
Alan J. Mayer
SGI
ajm@sgi.com
WORK: 651-683-3131
HOME: 651-407-0134
--

