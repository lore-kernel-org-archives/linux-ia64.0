From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 Jan 2005 23:19:03 +0000
Subject: state of the ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02C33881@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The 'bk pull' that I just sent to Linus includes all the code
that has been sitting in the "test-2.6.11" tree.  It's cooked
there for over a month, and been in the last couple of "-mm"
releases.

I still have lots of patches from the past couple of weeks to
put in, but I wanted to get this merge-in resolved first before
the patches get too stale to merge, or before we get too close
to the 2.6.11 release to include such big changes.

Everything I've tried (tiger, zx1, generic) works in SMP mode.

Uni-processor support is a mess right now.  Dan's resurrection
of Jesse's patches for generic-up support doesn't apply ... the
prime culprit is discontig.c:find_per_node_space() which has been
touched by several patches, so we still have lots of build
errors for generic-up.  tiger and zx1 systems do compile cleanly
with CONFIG_SMP=n, but the tiger stalls:

ICH4: BIOS configuration fixed.
ICH4: chipset revision 2
ICH4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0x1000-0x1007, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0x1008-0x100f, BIOS settings: hdc:pio, hdd:pio
!!!
!!! Uni-processor kernel stops here, SMP goes on to print:
!!!
hda: MATSHITADVD-ROM SR-8176, ATAPI CD/DVD-ROM drive
hdb: LS-120/240 00 UHD Floppy, ATAPI FLOPPY drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 34
hda: ATAPI 61X DVD-ROM drive, 256kB Cache, UDMA(33)
Uniform CD-ROM driver Revision: 3.20

zx1 (zx2000) doesn't print anything on the VGA, and the system
resets after 10 seconds.  I need to hook up a serial cable to
see if it spoke at all before dying.

-Tony
