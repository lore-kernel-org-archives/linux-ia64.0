From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Jan 2006 01:07:08 +0000
Subject: patches added to release/test trees
Message-Id: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patches have been added to the release tree (destined
to go into 2.6.16 when Linus gets back from linux.conf.au):

Dean Roe:
      [IA64-SGI] add sn_feature_sets bit

Greg Edwards:
      [IA64] sn2 maintainer update (Jes Sorensen)

Jack Steiner:
      [IA64] Scaling fix for simultaneous unaligned accesses

Jes Sorensen:
      [IA64-SGI] XPC remove unnecessary GFP_DMA flag

Keith Owens:
      [IA64] Set the correct default OS status in the MCA handler

Prarit Bhargava:
      [IA64-SGI] Add PROM feature set for device flush list

Takashi Iwai:
      [IA64-SGI] sn_dma_alloc_coherent should use gfp flags

All of the above and these patches have been added to the test tree (destined
for some -mm releases, and then 2.6.17):

Aaron Young:
      [IA64-SGI] Handle SC env. powerdown events

Brent Casavant:
      [IA64] hooks to wait for mmio writes to drain when migrating processes

Chen, Kenneth W:
      [IA64] implement ia64 specific mutex primitives

Jack Steiner:
      [IA64-SGI] Update TLB flushing code for SN platform

Jes Sorensen:
      [IA64-SGI] sem2mutex ioc4.c
      drivers/sn/ must be entered for CONFIG_SGI_IOC3

Keith Owens:
      [IA64-SGI] Recursive flags do not work for selective builds
      [IA64] Delete MCA/INIT sigdelayed code

Mark Maule:
      [IA64-SGI] driver bugfixes and hardware workarounds for CE1.0 asic
