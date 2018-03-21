From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 19:22:43 +0000
Subject: [PATCH 27/32] docs/vm: userfaultfd.txt: convert to ReST format
Message-Id: <1521660168-14372-28-git-send-email-rppt@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/userfaultfd.txt | 66 ++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 27 deletions(-)

diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
index bb2f945..5048cf6 100644
--- a/Documentation/vm/userfaultfd.txt
+++ b/Documentation/vm/userfaultfd.txt
@@ -1,6 +1,11 @@
-= Userfaultfd +.. _userfaultfd:
 
-= Objective =
+=====+Userfaultfd
+=====+
+Objective
+==== 
 Userfaults allow the implementation of on-demand paging from userland
 and more generally they allow userland to take control of various
@@ -9,7 +14,8 @@ memory page faults, something otherwise only the kernel code could do.
 For example userfaults allows a proper and more optimal implementation
 of the PROT_NONE+SIGSEGV trick.
 
-= Design =
+Design
+===
 
 Userfaults are delivered and resolved through the userfaultfd syscall.
 
@@ -41,7 +47,8 @@ different processes without them being aware about what is going on
 themselves on the same region the manager is already tracking, which
 is a corner case that would currently return -EBUSY).
 
-= API =
+API
+= 
 When first opened the userfaultfd must be enabled invoking the
 UFFDIO_API ioctl specifying a uffdio_api.api value set to UFFD_API (or
@@ -101,7 +108,8 @@ UFFDIO_COPY. They're atomic as in guaranteeing that nothing can see an
 half copied page since it'll keep userfaulting until the copy has
 finished.
 
-= QEMU/KVM =
+QEMU/KVM
+====
 
 QEMU/KVM is using the userfaultfd syscall to implement postcopy live
 migration. Postcopy live migration is one form of memory
@@ -163,7 +171,8 @@ sending the same page twice (in case the userfault is read by the
 postcopy thread just before UFFDIO_COPY|ZEROPAGE runs in the migration
 thread).
 
-= Non-cooperative userfaultfd =
+Non-cooperative userfaultfd
+============= 
 When the userfaultfd is monitored by an external manager, the manager
 must be able to track changes in the process virtual memory
@@ -172,27 +181,30 @@ the same read(2) protocol as for the page fault notifications. The
 manager has to explicitly enable these events by setting appropriate
 bits in uffdio_api.features passed to UFFDIO_API ioctl:
 
-UFFD_FEATURE_EVENT_FORK - enable userfaultfd hooks for fork(). When
-this feature is enabled, the userfaultfd context of the parent process
-is duplicated into the newly created process. The manager receives
-UFFD_EVENT_FORK with file descriptor of the new userfaultfd context in
-the uffd_msg.fork.
-
-UFFD_FEATURE_EVENT_REMAP - enable notifications about mremap()
-calls. When the non-cooperative process moves a virtual memory area to
-a different location, the manager will receive UFFD_EVENT_REMAP. The
-uffd_msg.remap will contain the old and new addresses of the area and
-its original length.
-
-UFFD_FEATURE_EVENT_REMOVE - enable notifications about
-madvise(MADV_REMOVE) and madvise(MADV_DONTNEED) calls. The event
-UFFD_EVENT_REMOVE will be generated upon these calls to madvise. The
-uffd_msg.remove will contain start and end addresses of the removed
-area.
-
-UFFD_FEATURE_EVENT_UNMAP - enable notifications about memory
-unmapping. The manager will get UFFD_EVENT_UNMAP with uffd_msg.remove
-containing start and end addresses of the unmapped area.
+UFFD_FEATURE_EVENT_FORK
+	enable userfaultfd hooks for fork(). When this feature is
+	enabled, the userfaultfd context of the parent process is
+	duplicated into the newly created process. The manager
+	receives UFFD_EVENT_FORK with file descriptor of the new
+	userfaultfd context in the uffd_msg.fork.
+
+UFFD_FEATURE_EVENT_REMAP
+	enable notifications about mremap() calls. When the
+	non-cooperative process moves a virtual memory area to a
+	different location, the manager will receive
+	UFFD_EVENT_REMAP. The uffd_msg.remap will contain the old and
+	new addresses of the area and its original length.
+
+UFFD_FEATURE_EVENT_REMOVE
+	enable notifications about madvise(MADV_REMOVE) and
+	madvise(MADV_DONTNEED) calls. The event UFFD_EVENT_REMOVE will
+	be generated upon these calls to madvise. The uffd_msg.remove
+	will contain start and end addresses of the removed area.
+
+UFFD_FEATURE_EVENT_UNMAP
+	enable notifications about memory unmapping. The manager will
+	get UFFD_EVENT_UNMAP with uffd_msg.remove containing start and
+	end addresses of the unmapped area.
 
 Although the UFFD_FEATURE_EVENT_REMOVE and UFFD_FEATURE_EVENT_UNMAP
 are pretty similar, they quite differ in the action expected from the
-- 
2.7.4

