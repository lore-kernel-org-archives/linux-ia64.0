From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 10 Jan 2016 14:20:26 +0000
Subject: [PATCH v3 28/41] asm-generic: implement virt_xxx memory barriers
Message-Id: <1452426622-4471-29-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452426622-4471-1-git-send-email-mst@redhat.com>
In-Reply-To: <1452426622-4471-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Jonathan Corbet <cor>

Guests running within virtual machines might be affected by SMP effects even if
the guest itself is compiled without SMP support.  This is an artifact of
interfacing with an SMP host while running an UP kernel.  Using mandatory
barriers for this use-case would be possible but is often suboptimal.

In particular, virtio uses a bunch of confusing ifdefs to work around
this, while xen just uses the mandatory barriers.

To better handle this case, low-level virt_mb() etc macros are made available.
These are implemented trivially using the low-level __smp_xxx macros,
the purpose of these wrappers is to annotate those specific cases.

These have the same effect as smp_mb() etc when SMP is enabled, but generate
identical code for SMP and non-SMP systems. For example, virtual machine guests
should use virt_mb() rather than smp_mb() when synchronizing against a
(possibly SMP) host.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/asm-generic/barrier.h     | 11 +++++++++++
 Documentation/memory-barriers.txt | 28 +++++++++++++++++++++++-----
 2 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index 8752964..1cceca14 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -196,5 +196,16 @@ do {									\
 
 #endif
 
+/* Barriers for virtual machine guests when talking to an SMP host */
+#define virt_mb() __smp_mb()
+#define virt_rmb() __smp_rmb()
+#define virt_wmb() __smp_wmb()
+#define virt_read_barrier_depends() __smp_read_barrier_depends()
+#define virt_store_mb(var, value) __smp_store_mb(var, value)
+#define virt_mb__before_atomic() __smp_mb__before_atomic()
+#define virt_mb__after_atomic()	__smp_mb__after_atomic()
+#define virt_store_release(p, v) __smp_store_release(p, v)
+#define virt_load_acquire(p) __smp_load_acquire(p)
+
 #endif /* !__ASSEMBLY__ */
 #endif /* __ASM_GENERIC_BARRIER_H */
diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
index aef9487..8f4a93a 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -1655,17 +1655,18 @@ macro is a good place to start looking.
 SMP memory barriers are reduced to compiler barriers on uniprocessor compiled
 systems because it is assumed that a CPU will appear to be self-consistent,
 and will order overlapping accesses correctly with respect to itself.
+However, see the subsection on "Virtual Machine Guests" below.
 
 [!] Note that SMP memory barriers _must_ be used to control the ordering of
 references to shared memory on SMP systems, though the use of locking instead
 is sufficient.
 
 Mandatory barriers should not be used to control SMP effects, since mandatory
-barriers unnecessarily impose overhead on UP systems. They may, however, be
-used to control MMIO effects on accesses through relaxed memory I/O windows.
-These are required even on non-SMP systems as they affect the order in which
-memory operations appear to a device by prohibiting both the compiler and the
-CPU from reordering them.
+barriers impose unnecessary overhead on both SMP and UP systems. They may,
+however, be used to control MMIO effects on accesses through relaxed memory I/O
+windows.  These barriers are required even on non-SMP systems as they affect
+the order in which memory operations appear to a device by prohibiting both the
+compiler and the CPU from reordering them.
 
 
 There are some more advanced barrier functions:
@@ -2948,6 +2949,23 @@ The Alpha defines the Linux kernel's memory barrier model.
 
 See the subsection on "Cache Coherency" above.
 
+VIRTUAL MACHINE GUESTS
+-------------------
+
+Guests running within virtual machines might be affected by SMP effects even if
+the guest itself is compiled without SMP support.  This is an artifact of
+interfacing with an SMP host while running an UP kernel.  Using mandatory
+barriers for this use-case would be possible but is often suboptimal.
+
+To handle this case optimally, low-level virt_mb() etc macros are available.
+These have the same effect as smp_mb() etc when SMP is enabled, but generate
+identical code for SMP and non-SMP systems. For example, virtual machine guests
+should use virt_mb() rather than smp_mb() when synchronizing against a
+(possibly SMP) host.
+
+These are equivalent to smp_mb() etc counterparts in all other respects,
+in particular, they do not control MMIO effects: to control
+MMIO effects, use mandatory barriers.
 
 ======
 EXAMPLE USES
-- 
MST

