From: Waiman Long <longman@redhat.com>
Date: Fri, 22 Mar 2019 14:30:08 +0000
Subject: [PATCH v5 3/3] locking/rwsem: Optimize down_read_trylock()
Message-Id: <20190322143008.21313-4-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190322143008.21313-1-longman@redhat.com>
In-Reply-To: <20190322143008.21313-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, uclinux-h8-devel@lists.sourceforge.jp, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <tor>

Modify __down_read_trylock() to optimize for an unlocked rwsem and make
it generate slightly better code.

Before this patch, down_read_trylock:

   0x0000000000000000 <+0>:     callq  0x5 <down_read_trylock+5>
   0x0000000000000005 <+5>:     jmp    0x18 <down_read_trylock+24>
   0x0000000000000007 <+7>:     lea    0x1(%rdx),%rcx
   0x000000000000000b <+11>:    mov    %rdx,%rax
   0x000000000000000e <+14>:    lock cmpxchg %rcx,(%rdi)
   0x0000000000000013 <+19>:    cmp    %rax,%rdx
   0x0000000000000016 <+22>:    je     0x23 <down_read_trylock+35>
   0x0000000000000018 <+24>:    mov    (%rdi),%rdx
   0x000000000000001b <+27>:    test   %rdx,%rdx
   0x000000000000001e <+30>:    jns    0x7 <down_read_trylock+7>
   0x0000000000000020 <+32>:    xor    %eax,%eax
   0x0000000000000022 <+34>:    retq
   0x0000000000000023 <+35>:    mov    %gs:0x0,%rax
   0x000000000000002c <+44>:    or     $0x3,%rax
   0x0000000000000030 <+48>:    mov    %rax,0x20(%rdi)
   0x0000000000000034 <+52>:    mov    $0x1,%eax
   0x0000000000000039 <+57>:    retq

After patch, down_read_trylock:

   0x0000000000000000 <+0>:	callq  0x5 <down_read_trylock+5>
   0x0000000000000005 <+5>:	xor    %eax,%eax
   0x0000000000000007 <+7>:	lea    0x1(%rax),%rdx
   0x000000000000000b <+11>:	lock cmpxchg %rdx,(%rdi)
   0x0000000000000010 <+16>:	jne    0x29 <down_read_trylock+41>
   0x0000000000000012 <+18>:	mov    %gs:0x0,%rax
   0x000000000000001b <+27>:	or     $0x3,%rax
   0x000000000000001f <+31>:	mov    %rax,0x20(%rdi)
   0x0000000000000023 <+35>:	mov    $0x1,%eax
   0x0000000000000028 <+40>:	retq
   0x0000000000000029 <+41>:	test   %rax,%rax
   0x000000000000002c <+44>:	jns    0x7 <down_read_trylock+7>
   0x000000000000002e <+46>:	xor    %eax,%eax
   0x0000000000000030 <+48>:	retq

By using a rwsem microbenchmark, the down_read_trylock() rate (with a
load of 10 to lengthen the lock critical section) on a x86-64 system
before and after the patch were:

                 Before Patch    After Patch
   # of Threads     rlock           rlock
   ------------     -----           -----
        1           14,496          14,716
        2            8,644           8,453
	4            6,799           6,983
	8            5,664           7,190

On a ARM64 system, the performance results were:

                 Before Patch    After Patch
   # of Threads     rlock           rlock
   ------------     -----           -----
        1           23,676          24,488
        2            7,697           9,502
        4            4,945           3,440
        8            2,641           1,603

For the uncontended case (1 thread), the new down_read_trylock() is a
little bit faster. For the contended cases, the new down_read_trylock()
perform pretty well in x86-64, but performance degrades at high
contention level on ARM64.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem.h | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
index 45ee00236e03..1f5775aa6a1d 100644
--- a/kernel/locking/rwsem.h
+++ b/kernel/locking/rwsem.h
@@ -174,14 +174,17 @@ static inline int __down_read_killable(struct rw_semaphore *sem)
 
 static inline int __down_read_trylock(struct rw_semaphore *sem)
 {
-	long tmp;
+	/*
+	 * Optimize for the case when the rwsem is not locked at all.
+	 */
+	long tmp = RWSEM_UNLOCKED_VALUE;
 
-	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
-		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
-				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
+	do {
+		if (atomic_long_try_cmpxchg_acquire(&sem->count, &tmp,
+					tmp + RWSEM_ACTIVE_READ_BIAS)) {
 			return 1;
 		}
-	}
+	} while (tmp >= 0);
 	return 0;
 }
 
-- 
2.18.1
