From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 15 Oct 2004 19:02:44 +0000
Subject: page fault scalability patch V10: [0/7] overview
Message-Id: <Pine.LNX.4.58.0410151201020.26697@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0409201348070.4628@schroedinger.engr.sgi.com>
 <20040920205752.GH4242@wotan.suse.de> <200409211841.25507.vda@port.imtp.ilyichevsk.odessa.ua>
 <20040921154542.GB12132@wotan.suse.de> <41527885.8020402@myrealbox.com>
 <20040923090345.GA6146@wotan.suse.de> <Pine.LNX.4.58.0409271204180.31769@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0409271204180.31769@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Changes from V9->V10 of this patch:
- generic: fixes and updates
- S390: changes after feedback from Martin Schwidefsky
- x86_64: tested and now works fine.
- i386: stable
- ia64: stable. Added support for pte_locking necessary
	for a planned parallelization of COW.

This is a series of patches that increases the scalability of
the page fault handler for SMP. Typical performance increases in the page
fault rate are:

2 CPUs -> 30%
4 CPUs -> 45%
8 CPUs -> 60%

With a high number of CPUs (16..512) we are seeing the page fault rate
roughly doubling.

The performance increase is accomplished by avoiding the use of the
page_table_lock spinlock (but not mm->mmap_sem!) through new atomic
operations on pte's (ptep_xchg, ptep_cmpxchg) and on pmd and pgd's
(pgd_test_and_populate, pmd_test_and_populate).

The page table lock can be avoided in the following situations:

1. An empty pte or pmd entry is populated

This is safe since the swapper may only depopulate them and the
swapper code has been changed to never set a pte to be empty until the
page has been evicted. The population of an empty pte is frequent
if a process touches newly allocated memory.

2. Modifications of flags in a pte entry (write/accessed).

These modifications are done by the CPU or by low level handlers
on various platforms also bypassing the page_table_lock. So this
seems to be safe too.

The patchset is composed of 7 patches:

1/7: Make mm->rss atomic

   The page table lock is used to protect mm->rss and the first patch
   makes rss atomic so that it may be changed without holding the
   page_table_lock.
   Generic atomic variables are only 32 bit under Linux. However, 32 bits
   is sufficient for rss even on a 64 bit machine since rss refers to the
   number of pages allowing still up to 2^(31+12)= 8 terabytes of memory
   to be in use by a single process. A 64 bit atomic would of course be better.

2/7: Avoid page_table_lock in handle_mm_fault

   This patch defers the acquisition of the page_table_lock as much as
   possible and uses atomic operations for allocating anonymous memory.
   These atomic operations are simulated by acquiring the page_table_lock
   for very small time frames if an architecture does not define
   __HAVE_ARCH_ATOMIC_TABLE_OPS. It also changes the swapper so that a
   pte will not be set to empty if a page is in transition to swap.

   If only the first two patches are applied then the time that the page_table_lock
   is held is simply reduced. The lock may then be acquired multiple
   times during a page fault.

   The remaining patches introduce the necessary atomic pte operations to avoid
   the page_table_lock.

3/7: Atomic pte operations for ia64

4/7: Make cmpxchg generally available on i386

   The atomic operations on the page table rely heavily on cmpxchg instructions.
   This patch adds emulations for cmpxchg and cmpxchg8b for old 80386 and 80486
   cpus. The emulations are only included if a kernel is build for these old
   cpus and are skipped for the real cmpxchg instructions if the kernel
   that is build for 386 or 486 is then run on a more recent cpu.

   This patch may be used independently of the other patches.

5/7: Atomic pte operations for i386

   A generally available cmpxchg (last patch) must be available for this patch to
   preserve the ability to build kernels for 386 and 486.

6/7: Atomic pte operation for x86_64

7/7: Atomic pte operations for s390
