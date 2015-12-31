From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 31 Dec 2015 19:05:36 +0000
Subject: [PATCH v2 00/34] arch: barrier cleanup + barriers for virt
Message-Id: <1451572003-2440-1-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, user-mode-linux-devel@lists.sourceforge.net, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Cooper <andrew.cooper3@citrix.com>, linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>

Changes since v1:
	- replaced my asm-generic patch with an equivalent patch already in tip
	- add wrappers with virt_ prefix for better code annotation,
	  as suggested by David Miller
	- dropped XXX in patch names as this makes vger choke, Cc all relevant
	  mailing lists on all patches (not personal email, as the list becomes
	  too long then)

I parked this in vhost tree for now, but the inclusion of patch 1 from tip
creates a merge conflict (even though it's easy to resolve).
Would tip maintainers prefer merging it through tip tree instead
(including the virtio patches)?
Or should I just merge it all through my tree, including the
duplicate patch, and assume conflict will be resolved?
If the second, acks will be appreciated.

Thanks!

This is really trying to cleanup some virt code, as suggested by Peter, who
said
> You could of course go fix that instead of mutilating things into
> sort-of functional state.

This work is needed for virtio, so it's probably easiest to
merge it through my tree - is this fine by everyone?
Arnd, if you agree, could you ack this please?

Note to arch maintainers: please don't cherry-pick patches out of this patchset
as it's been structured in this order to avoid breaking bisect.
Please send acks instead!

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
about a net reduction in LOC, even with new barriers and extra documentation :)

Then virt can use __smp_XXX when talking to an SMP host.
To make those users explicit, this patchset adds virt_xxx wrappers
for them.

Touching all archs is a tad tedious, but its fairly straight forward.

The rest of the patchset is structured as follows:


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

-. Patches 13 adds generic smp_XXX wrappers in asm-generic
   these select __smp_XXX or barrier() depending on CONFIG_SMP

-. Patches 14-27 change all architectures to
   define __smp_XXX macros; the generic code in asm-generic/barrier.h
   then defines smp_XXX macros

   I compiled the affected arches before and after the changes,
   dumped the .text section (using objdump -O binary) and
   made sure that the object code is exactly identical
   before and after the change.
   I couldn't fully build sh,tile,xtensa but I did this test
   kernel/rcu/tree.o kernel/sched/wait.o and
   kernel/futex.o and tested these instead.

Unfortunately, I don't have a metag cross-build toolset ready.
Hoping for some acks on this architecture.

Finally, the following patches put the __smp_xxx APIs to work for virt:

-. Patch 28 adds virt_ wrappers for __smp_, and documents them.
   After all this work, this requires very few lines of code in
   the generic header.

-. Patches 29,30,33,34 convert virtio xen drivers to use the virt_xxx APIs

   xen patches are untested
   virtio ones have been tested on x86

-. Patches 31-32 teach virtio to use virt_store_mb
   sh architecture was missing a 2-byte smp_store_mb,
   the fix is trivial although my code is not optimal:
   if anyone cares, pls send me a patch to apply on top.
   I didn't build this architecture, but intel's 0-day
   infrastructure builds it.

   tested on x86


Davidlohr Bueso (1):
  lcoking/barriers, arch: Use smp barriers in smp_store_release()

Michael S. Tsirkin (33):
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
  virtio_ring: update weak barriers to use __smp_XXX
  sh: support a 2-byte smp_store_mb
  virtio_ring: use virt_store_mb
  xenbus: use virt_xxx barriers
  xen/io: use virt_xxx barriers

 arch/arm/include/asm/barrier.h      |  35 ++-----------
 arch/arm64/include/asm/barrier.h    |  19 +++----
 arch/blackfin/include/asm/barrier.h |   4 +-
 arch/ia64/include/asm/barrier.h     |  24 +++------
 arch/metag/include/asm/barrier.h    |  55 ++++++-------------
 arch/mips/include/asm/barrier.h     |  51 ++++++------------
 arch/powerpc/include/asm/barrier.h  |  33 ++++--------
 arch/s390/include/asm/barrier.h     |  25 ++++-----
 arch/sh/include/asm/barrier.h       |  11 +++-
 arch/sparc/include/asm/barrier_32.h |   1 -
 arch/sparc/include/asm/barrier_64.h |  29 +++-------
 arch/sparc/include/asm/processor.h  |   3 --
 arch/tile/include/asm/barrier.h     |   9 ++--
 arch/x86/include/asm/barrier.h      |  36 +++++--------
 arch/x86/um/asm/barrier.h           |   9 +---
 arch/xtensa/include/asm/barrier.h   |   4 +-
 include/asm-generic/barrier.h       | 102 ++++++++++++++++++++++++++++++++----
 include/linux/virtio_ring.h         |  22 +++++---
 include/xen/interface/io/ring.h     |  16 +++---
 arch/ia64/kernel/iosapic.c          |   6 +--
 drivers/virtio/virtio_ring.c        |  15 +++---
 drivers/xen/xenbus/xenbus_comms.c   |   8 +--
 Documentation/memory-barriers.txt   |  28 ++++++++--
 23 files changed, 266 insertions(+), 279 deletions(-)

-- 
MST

