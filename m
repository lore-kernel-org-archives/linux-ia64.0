From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:16:22 +0000
Subject: [PATCH v3 00/41] arch: barrier cleanup + barriers for virt
Message-Id: <1452426622-4471-1-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org

Changes since v2:
	- extended checkpatch tests for barriers, and added patches
	teaching it to warn about incorrect usage of barriers
	(__smp_xxx barriers are for use by asm-generic code only),
	should help prevent misuse by arch code
	to address comments by Russell King
	- patched more instances of xen to use virt_ barriers
	as suggested by  Stefano Stabellini
	- implemented a 2 byte xchg on sh instead of hacking around it
	as suggested by Peter Zijlstra and  Rich Felker
	- added a patch to drop some s390 arch-specific smp_xxx barriers - generic
	versions are more efficient
	as suggested by Peter Zijlstra and Martin Schwidefsky
	- added a patch to replace before/after atomic barriers with barrier()
	on s390 as suggested by Peter Zijlstra and Martin Schwidefsky
	- included acks from multiple arch maintainers
	thanks a lot for the review!

Changes since v1:
	- replaced an asm-generic patch with an equivalent patch already in tip
	- add wrappers with virt_ prefix for better code annotation,
	  as suggested by David Miller
	- dropped XXX in patch names as this makes vger choke, Cc all relevant
	  mailing lists on all patches (not personal email, as the list becomes
	  too long then)

I parked this in vhost tree for now, though the inclusion of patch 1 from tip
creates a merge conflict - but one that is trivial to resolve.

So I intend to just merge it all through my tree, including the
duplicate patch, and assume conflict will be resolved.

I would really appreciate some feedback on arch bits (especially the x86 bits),
and acks for merging this through the vhost tree.

Thanks!

What really started me off is trying to cleanup some virt code, as suggested by
Peter, who said
> You could of course go fix that instead of mutilating things into
> sort-of functional state.

This work is needed for virtio, so it's probably easiest to
merge it through my tree - is this fine by everyone?

Note to arch maintainers: please don't cherry-pick patches out of this patchset
as it's been structured in this order to avoid breaking bisect.
Please send acks instead!

==
Sometimes, virtualization is weird. For example, virtio does this (conceptually):

#ifdef CONFIG_SMP
                smp_mb();
#else
                mb();
#endif

Similarly, Xen calls mb() when it's not doing any MMIO at all.

Of course it's wrong in the sense that it's suboptimal. What we would really
like is to have, on UP, exactly the same barrier as on SMP.  This is because a
UP guest can run on an SMP host.

But Linux doesn't provide this ability: if CONFIG_SMP is not defined is
optimizes most barriers out to a compiler barrier.

Consider for example x86: what we want is xchg (NOT mfence - there's no real IO
going on here - just switching out of the VM - more like a function call
really) but if built without CONFIG_SMP smp_store_mb does not include this.

Virt in general is probably the only use-case, because this really is an
artifact of interfacing with an SMP host while running an UP kernel,
but since we have (at least) two users, it seems to make sense to
put these APIs in a central place.

In fact, smp_ barriers are stubs on !SMP, so they can be defined as follows:

arch/XXX/include/asm/barrier.h:

#define __smp_mb() DOSOMETHING

include/asm-generic/barrier.h:

#ifdef CONFIG_SMP
#define smp_mb() __smp_mb()
#else
#define smp_mb() barrier()
#endif

This has the benefit of cleaning out a bunch of duplicated
ifdefs on a bunch of architectures - this patchset brings
about a net reduction in LOC, more than compensated for
later by performance enhancements, extra documentation and tools :)

Then virt can use __smp_XXX when talking to an SMP host.
To make those users explicit, this patchset adds virt_xxx wrappers
for them.

Touching all archs is a tad tedious, but its fairly straight forward.

The patchset is structured as follows:


-. Patch 1 fixes a bug in asm-generic.
   It is already in tip, included here for completeness.

-. Patches 2-12 make sure barrier.h on all remaining
   architectures includes asm-generic/barrier.h:
   after the change in Patch 1, code there matches
   asm-generic/barrier.h almost verbatim.
   Minor code tweaks were required in a couple of places.
   Macros duplicated from asm-generic/barrier.h are dropped
   in the process.

After all that preparatory work, we are getting to the actual change.

-. Patch 13 adds generic smp_XXX wrappers in asm-generic:
   these select __smp_XXX or barrier() depending on CONFIG_SMP

-. Patches 14-27 change all architectures to
   define __smp_XXX macros; the generic code in asm-generic/barrier.h
   then defines smp_XXX macros

   I compiled the affected arches before and after the changes,
   dumped the .text section (using objdump -O binary) and
   made sure that the object code is exactly identical
   before and after the change.

   Note: the changes were intentionally done in a way
   that avoids generated code changes.
   When I got feedback from arch maintainers that the
   barriers can be improved, I made this in a separate
   patch on top, to allow this testing by binary comparisons.

Unfortunately, I don't have a metag cross-build toolset ready.
Hoping for some acks on this architecture.

Next, the following patches put the __smp_xxx APIs to work for virt:

-. Patch 28 adds virt_ wrappers for __smp_, and documents them.
   After all this work, this requires very few lines of code in
   the generic header.

-. Patches 29,30 convert virtio drivers to use the virt_xxx APIs
   tested on x86

-. Patches 31-33 teach virtio to use virt_store_mb
   sh architecture was missing a 2-byte xchg,
   needed for 2 byte smp_store_mb,
   so I had to add this support for sh

-. Patches 34-36 teach checkpatch to warn about
   misuse of the new barriers

-. Patches 37-39 convert xen drivers to use the virt_xxx APIs
   compiled only (by intel 0-day infrastructure)

-. Patch 40 makes some smp barriers on s390 more efficient
   included here to avoid merge conflicts, at maintainer's request

   tested on x86
Davidlohr Bueso (1):
  lcoking/barriers, arch: Use smp barriers in smp_store_release()

Michael S. Tsirkin (40):
  asm-generic: guard smp_store_release/load_acquire
  ia64: rename nop->iosapic_nop
  ia64: reuse asm-generic/barrier.h
  powerpc: reuse asm-generic/barrier.h
  s390: reuse asm-generic/barrier.h
  sparc: reuse asm-generic/barrier.h
  arm: reuse asm-generic/barrier.h
  arm64: reuse asm-generic/barrier.h
  metag: reuse asm-generic/barrier.h
  mips: reuse asm-generic/barrier.h
  x86/um: reuse asm-generic/barrier.h
  x86: reuse asm-generic/barrier.h
  asm-generic: add __smp_xxx wrappers
  powerpc: define __smp_xxx
  arm64: define __smp_xxx
  arm: define __smp_xxx
  blackfin: define __smp_xxx
  ia64: define __smp_xxx
  metag: define __smp_xxx
  mips: define __smp_xxx
  s390: define __smp_xxx
  sh: define __smp_xxx, fix smp_store_mb for !SMP
  sparc: define __smp_xxx
  tile: define __smp_xxx
  xtensa: define __smp_xxx
  x86: define __smp_xxx
  asm-generic: implement virt_xxx memory barriers
  Revert "virtio_ring: Update weak barriers to use dma_wmb/rmb"
  virtio_ring: update weak barriers to use virt_xxx
  sh: support 1 and 2 byte xchg
  sh: move xchg_cmpxchg to a header by itself
  virtio_ring: use virt_store_mb
  checkpatch.pl: add missing memory barriers
  checkpatch: check for __smp outside barrier.h
  checkpatch: add virt barriers
  xenbus: use virt_xxx barriers
  xen/io: use virt_xxx barriers
  xen/events: use virt_xxx barriers
  s390: use generic memory barriers
  s390: more efficient smp barriers

 arch/arm/include/asm/barrier.h      |  35 ++----------
 arch/arm64/include/asm/barrier.h    |  19 ++-----
 arch/blackfin/include/asm/barrier.h |   4 +-
 arch/ia64/include/asm/barrier.h     |  24 +++-----
 arch/metag/include/asm/barrier.h    |  55 ++++++-------------
 arch/mips/include/asm/barrier.h     |  51 ++++++-----------
 arch/powerpc/include/asm/barrier.h  |  33 ++++-------
 arch/s390/include/asm/barrier.h     |  23 ++++----
 arch/sh/include/asm/barrier.h       |   3 +-
 arch/sh/include/asm/cmpxchg-grb.h   |  22 ++++++++
 arch/sh/include/asm/cmpxchg-irq.h   |  11 ++++
 arch/sh/include/asm/cmpxchg-llsc.h  |  25 +--------
 arch/sh/include/asm/cmpxchg-xchg.h  |  51 +++++++++++++++++
 arch/sh/include/asm/cmpxchg.h       |   3 +
 arch/sparc/include/asm/barrier_32.h |   1 -
 arch/sparc/include/asm/barrier_64.h |  29 ++--------
 arch/sparc/include/asm/processor.h  |   3 -
 arch/tile/include/asm/barrier.h     |   9 +--
 arch/x86/include/asm/barrier.h      |  36 +++++-------
 arch/x86/um/asm/barrier.h           |   9 +--
 arch/xtensa/include/asm/barrier.h   |   4 +-
 include/asm-generic/barrier.h       | 106 +++++++++++++++++++++++++++++++++---
 include/linux/virtio_ring.h         |  21 +++++--
 include/xen/interface/io/ring.h     |  16 +++---
 arch/ia64/kernel/iosapic.c          |   6 +-
 drivers/virtio/virtio_ring.c        |  15 +++--
 drivers/xen/events/events_fifo.c    |   3 +-
 drivers/xen/xenbus/xenbus_comms.c   |   8 +--
 Documentation/memory-barriers.txt   |  28 ++++++++--
 scripts/checkpatch.pl               |  31 ++++++++++-
 30 files changed, 382 insertions(+), 302 deletions(-)
 create mode 100644 arch/sh/include/asm/cmpxchg-xchg.h

-- 
MST

