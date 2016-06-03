From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 03 Jun 2016 16:13:39 +0000
Subject: Re: [RFC 10/12] x86, rwsem: simplify __down_write
Message-Id: <20160603161339.GC3693@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <1454444369-2146-11-git-send-email-mhocko@kernel.org>
 <20160203081016.GD32652@gmail.com>
In-Reply-To: <20160203081016.GD32652@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@us.ibm.com>

On Wed, Feb 03, 2016 at 09:10:16AM +0100, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > x86 implementation of __down_write is using inline asm to optimize the
> > code flow. This however requires that it has go over an additional hop
> > for the slow path call_rwsem_down_write_failed which has to
> > save_common_regs/restore_common_regs to preserve the calling convention.
> > This, however doesn't add much because the fast path only saves one
> > register push/pop (rdx) when compared to the generic implementation:
> > 
> > Before:
> > 0000000000000019 <down_write>:
> >   19:   e8 00 00 00 00          callq  1e <down_write+0x5>
> >   1e:   55                      push   %rbp
> >   1f:   48 ba 01 00 00 00 ff    movabs $0xffffffff00000001,%rdx
> >   26:   ff ff ff
> >   29:   48 89 f8                mov    %rdi,%rax
> >   2c:   48 89 e5                mov    %rsp,%rbp
> >   2f:   f0 48 0f c1 10          lock xadd %rdx,(%rax)
> >   34:   85 d2                   test   %edx,%edx
> >   36:   74 05                   je     3d <down_write+0x24>
> >   38:   e8 00 00 00 00          callq  3d <down_write+0x24>
> >   3d:   65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
> >   44:   00 00
> >   46:   5d                      pop    %rbp
> >   47:   48 89 47 38             mov    %rax,0x38(%rdi)
> >   4b:   c3                      retq
> > 
> > After:
> > 0000000000000019 <down_write>:
> >   19:   e8 00 00 00 00          callq  1e <down_write+0x5>
> >   1e:   55                      push   %rbp
> >   1f:   48 b8 01 00 00 00 ff    movabs $0xffffffff00000001,%rax
> >   26:   ff ff ff
> >   29:   48 89 e5                mov    %rsp,%rbp
> >   2c:   53                      push   %rbx
> >   2d:   48 89 fb                mov    %rdi,%rbx
> >   30:   f0 48 0f c1 07          lock xadd %rax,(%rdi)
> >   35:   48 85 c0                test   %rax,%rax
> >   38:   74 05                   je     3f <down_write+0x26>
> >   3a:   e8 00 00 00 00          callq  3f <down_write+0x26>
> >   3f:   65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
> >   46:   00 00
> >   48:   48 89 43 38             mov    %rax,0x38(%rbx)
> >   4c:   5b                      pop    %rbx
> >   4d:   5d                      pop    %rbp
> >   4e:   c3                      retq
> 
> I'm not convinced about the removal of this optimization at all.

So I've been playing with this again because Jason's atomic_long_t
patches made a mess of things.

(similar findings for both ia64 and s390, suggesting killing all
arch/*/include/asm/rwsem.h might actuyally be an option).

Here's what I get (gcc-5.3.0):

# size x86_64-defconfig/vmlinux.{orig,mod}
   text    data     bss     dec     hex filename
10193229        4340512 1105920 15639661         eea46d x86_64-defconfig/vmlinux.orig
10193101        4340512 1105920 15639533         eea3ed x86_64-defconfig/vmlinux.mod

# objdump -D x86_64-defconfig/vmlinux.orig | awk '/<[^>]*>:$/ { p=0; } /<down_write>:/ { p=1; } { if (p) print $0; }'
ffffffff818d0d80 <down_write>:
ffffffff818d0d80:       55                      push   %rbp
ffffffff818d0d81:       48 89 e5                mov    %rsp,%rbp
ffffffff818d0d84:       53                      push   %rbx
ffffffff818d0d85:       48 89 fb                mov    %rdi,%rbx
ffffffff818d0d88:       e8 33 e3 ff ff          callq  ffffffff818cf0c0 <_cond_resched>
ffffffff818d0d8d:       48 ba 01 00 00 00 ff    movabs $0xffffffff00000001,%rdx
ffffffff818d0d94:       ff ff ff 
ffffffff818d0d97:       48 89 d8                mov    %rbx,%rax
ffffffff818d0d9a:       f0 48 0f c1 10          lock xadd %rdx,(%rax)
ffffffff818d0d9f:       85 d2                   test   %edx,%edx
ffffffff818d0da1:       74 05                   je     ffffffff818d0da8 <down_write+0x28>
ffffffff818d0da3:       e8 b8 d0 a5 ff          callq  ffffffff8132de60 <call_rwsem_down_write_failed>
ffffffff818d0da8:       65 48 8b 04 25 00 c4    mov    %gs:0xc400,%rax
ffffffff818d0daf:       00 00 
ffffffff818d0db1:       48 89 43 20             mov    %rax,0x20(%rbx)
ffffffff818d0db5:       5b                      pop    %rbx
ffffffff818d0db6:       5d                      pop    %rbp
ffffffff818d0db7:       c3                      retq   
ffffffff818d0db8:       0f 1f 84 00 00 00 00    nopl   0x0(%rax,%rax,1)
ffffffff818d0dbf:       00 

^C
# objdump -D x86_64-defconfig/vmlinux.mod | awk '/<[^>]*>:$/ { p=0; } /<down_write>:/ { p=1; } { if (p) print $0; }'
ffffffff818d0cf0 <down_write>:
ffffffff818d0cf0:       55                      push   %rbp
ffffffff818d0cf1:       48 89 e5                mov    %rsp,%rbp
ffffffff818d0cf4:       53                      push   %rbx
ffffffff818d0cf5:       48 89 fb                mov    %rdi,%rbx
ffffffff818d0cf8:       e8 23 e3 ff ff          callq  ffffffff818cf020 <_cond_resched>
ffffffff818d0cfd:       48 b8 01 00 00 00 ff    movabs $0xffffffff00000001,%rax
ffffffff818d0d04:       ff ff ff 
ffffffff818d0d07:       f0 48 0f c1 03          lock xadd %rax,(%rbx)
ffffffff818d0d0c:       48 85 c0                test   %rax,%rax
ffffffff818d0d0f:       75 10                   jne    ffffffff818d0d21 <down_write+0x31>
ffffffff818d0d11:       65 48 8b 04 25 00 c4    mov    %gs:0xc400,%rax
ffffffff818d0d18:       00 00 
ffffffff818d0d1a:       48 89 43 20             mov    %rax,0x20(%rbx)
ffffffff818d0d1e:       5b                      pop    %rbx
ffffffff818d0d1f:       5d                      pop    %rbp
ffffffff818d0d20:       c3                      retq   
ffffffff818d0d21:       48 89 df                mov    %rbx,%rdi
ffffffff818d0d24:       e8 f7 06 00 00          callq  ffffffff818d1420 <rwsem_down_write_failed>
ffffffff818d0d29:       eb e6                   jmp    ffffffff818d0d11 <down_write+0x21>
ffffffff818d0d2b:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)

---

diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index aeac434..1262556 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -10,3 +10,4 @@ generic-y += dma-contiguous.h
 generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
+generic-y += rwsem.h
diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
deleted file mode 100644
index 089ced4..0000000
--- a/arch/x86/include/asm/rwsem.h
+++ /dev/null
@@ -1,217 +0,0 @@
-/* rwsem.h: R/W semaphores implemented using XADD/CMPXCHG for i486+
- *
- * Written by David Howells (dhowells@redhat.com).
- *
- * Derived from asm-x86/semaphore.h
- *
- *
- * The MSW of the count is the negated number of active writers and waiting
- * lockers, and the LSW is the total number of active locks
- *
- * The lock count is initialized to 0 (no active and no waiting lockers).
- *
- * When a writer subtracts WRITE_BIAS, it'll get 0xffff0001 for the case of an
- * uncontended lock. This can be determined because XADD returns the old value.
- * Readers increment by 1 and see a positive value when uncontended, negative
- * if there are writers (and maybe) readers waiting (in which case it goes to
- * sleep).
- *
- * The value of WAITING_BIAS supports up to 32766 waiting processes. This can
- * be extended to 65534 by manually checking the whole MSW rather than relying
- * on the S flag.
- *
- * The value of ACTIVE_BIAS supports up to 65535 active processes.
- *
- * This should be totally fair - if anything is waiting, a process that wants a
- * lock will go to the back of the queue. When the currently active lock is
- * released, if there's a writer at the front of the queue, then that and only
- * that will be woken up; if there's a bunch of consecutive readers at the
- * front, then they'll all be woken up, but no other readers will be.
- */
-
-#ifndef _ASM_X86_RWSEM_H
-#define _ASM_X86_RWSEM_H
-
-#ifndef _LINUX_RWSEM_H
-#error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
-#endif
-
-#ifdef __KERNEL__
-#include <asm/asm.h>
-
-/*
- * The bias values and the counter type limits the number of
- * potential readers/writers to 32767 for 32 bits and 2147483647
- * for 64 bits.
- */
-
-#ifdef CONFIG_X86_64
-# define RWSEM_ACTIVE_MASK		0xffffffffL
-#else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
-#endif
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	asm volatile("# beginning down_read\n\t"
-		     LOCK_PREFIX _ASM_INC "(%1)\n\t"
-		     /* adds 0x00000001 */
-		     "  jns        1f\n"
-		     "  call call_rwsem_down_read_failed\n"
-		     "1:\n\t"
-		     "# ending down_read\n\t"
-		     : "+m" (sem->count)
-		     : "a" (sem)
-		     : "memory", "cc");
-}
-
-/*
- * trylock for reading -- returns 1 if successful, 0 if contention
- */
-static inline int __down_read_trylock(struct rw_semaphore *sem)
-{
-	long result, tmp;
-	asm volatile("# beginning __down_read_trylock\n\t"
-		     "  mov          %0,%1\n\t"
-		     "1:\n\t"
-		     "  mov          %1,%2\n\t"
-		     "  add          %3,%2\n\t"
-		     "  jle	     2f\n\t"
-		     LOCK_PREFIX "  cmpxchg  %2,%0\n\t"
-		     "  jnz	     1b\n\t"
-		     "2:\n\t"
-		     "# ending __down_read_trylock\n\t"
-		     : "+m" (sem->count), "=&a" (result), "=&r" (tmp)
-		     : "i" (RWSEM_ACTIVE_READ_BIAS)
-		     : "memory", "cc");
-	return result >= 0 ? 1 : 0;
-}
-
-/*
- * lock for writing
- */
-#define ____down_write(sem, slow_path)			\
-({							\
-	long tmp;					\
-	struct rw_semaphore* ret;			\
-	asm volatile("# beginning down_write\n\t"	\
-		     LOCK_PREFIX "  xadd      %1,(%3)\n\t"	\
-		     /* adds 0xffff0001, returns the old value */ \
-		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t" \
-		     /* was the active mask 0 before? */\
-		     "  jz        1f\n"			\
-		     "  call " slow_path "\n"		\
-		     "1:\n"				\
-		     "# ending down_write"		\
-		     : "+m" (sem->count), "=d" (tmp), "=a" (ret)	\
-		     : "a" (sem), "1" (RWSEM_ACTIVE_WRITE_BIAS) \
-		     : "memory", "cc");			\
-	ret;						\
-})
-
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	____down_write(sem, "call_rwsem_down_write_failed");
-}
-
-static inline int __down_write_killable(struct rw_semaphore *sem)
-{
-	if (IS_ERR(____down_write(sem, "call_rwsem_down_write_failed_killable")))
-		return -EINTR;
-
-	return 0;
-}
-
-/*
- * trylock for writing -- returns 1 if successful, 0 if contention
- */
-static inline int __down_write_trylock(struct rw_semaphore *sem)
-{
-	long result, tmp;
-	asm volatile("# beginning __down_write_trylock\n\t"
-		     "  mov          %0,%1\n\t"
-		     "1:\n\t"
-		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t"
-		     /* was the active mask 0 before? */
-		     "  jnz          2f\n\t"
-		     "  mov          %1,%2\n\t"
-		     "  add          %3,%2\n\t"
-		     LOCK_PREFIX "  cmpxchg  %2,%0\n\t"
-		     "  jnz	     1b\n\t"
-		     "2:\n\t"
-		     "  sete         %b1\n\t"
-		     "  movzbl       %b1, %k1\n\t"
-		     "# ending __down_write_trylock\n\t"
-		     : "+m" (sem->count), "=&a" (result), "=&r" (tmp)
-		     : "er" (RWSEM_ACTIVE_WRITE_BIAS)
-		     : "memory", "cc");
-	return result;
-}
-
-/*
- * unlock after reading
- */
-static inline void __up_read(struct rw_semaphore *sem)
-{
-	long tmp;
-	asm volatile("# beginning __up_read\n\t"
-		     LOCK_PREFIX "  xadd      %1,(%2)\n\t"
-		     /* subtracts 1, returns the old value */
-		     "  jns        1f\n\t"
-		     "  call call_rwsem_wake\n" /* expects old value in %edx */
-		     "1:\n"
-		     "# ending __up_read\n"
-		     : "+m" (sem->count), "=d" (tmp)
-		     : "a" (sem), "1" (-RWSEM_ACTIVE_READ_BIAS)
-		     : "memory", "cc");
-}
-
-/*
- * unlock after writing
- */
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	long tmp;
-	asm volatile("# beginning __up_write\n\t"
-		     LOCK_PREFIX "  xadd      %1,(%2)\n\t"
-		     /* subtracts 0xffff0001, returns the old value */
-		     "  jns        1f\n\t"
-		     "  call call_rwsem_wake\n" /* expects old value in %edx */
-		     "1:\n\t"
-		     "# ending __up_write\n"
-		     : "+m" (sem->count), "=d" (tmp)
-		     : "a" (sem), "1" (-RWSEM_ACTIVE_WRITE_BIAS)
-		     : "memory", "cc");
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	asm volatile("# beginning __downgrade_write\n\t"
-		     LOCK_PREFIX _ASM_ADD "%2,(%1)\n\t"
-		     /*
-		      * transitions 0xZZZZ0001 -> 0xYYYY0001 (i386)
-		      *     0xZZZZZZZZ00000001 -> 0xYYYYYYYY00000001 (x86_64)
-		      */
-		     "  jns       1f\n\t"
-		     "  call call_rwsem_downgrade_wake\n"
-		     "1:\n\t"
-		     "# ending __downgrade_write\n"
-		     : "+m" (sem->count)
-		     : "a" (sem), "er" (-RWSEM_WAITING_BIAS)
-		     : "memory", "cc");
-}
-
-#endif /* __KERNEL__ */
-#endif /* _ASM_X86_RWSEM_H */
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index 72a5767..c47dd5f 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -22,7 +22,6 @@ obj-$(CONFIG_SMP) += msr-smp.o cache-smp.o
 lib-y := delay.o misc.o cmdline.o cpu.o
 lib-y += usercopy_$(BITS).o usercopy.o getuser.o putuser.o
 lib-y += memcpy_$(BITS).o
-lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
 
 obj-y += msr.o msr-reg.o msr-reg-export.o
diff --git a/arch/x86/lib/rwsem.S b/arch/x86/lib/rwsem.S
deleted file mode 100644
index bf2c607..0000000
--- a/arch/x86/lib/rwsem.S
+++ /dev/null
@@ -1,144 +0,0 @@
-/*
- * x86 semaphore implementation.
- *
- * (C) Copyright 1999 Linus Torvalds
- *
- * Portions Copyright 1999 Red Hat, Inc.
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- *
- * rw semaphores implemented November 1999 by Benjamin LaHaise <bcrl@kvack.org>
- */
-
-#include <linux/linkage.h>
-#include <asm/alternative-asm.h>
-#include <asm/frame.h>
-
-#define __ASM_HALF_REG(reg)	__ASM_SEL(reg, e##reg)
-#define __ASM_HALF_SIZE(inst)	__ASM_SEL(inst##w, inst##l)
-
-#ifdef CONFIG_X86_32
-
-/*
- * The semaphore operations have a special calling sequence that
- * allow us to do a simpler in-line version of them. These routines
- * need to convert that sequence back into the C sequence when
- * there is contention on the semaphore.
- *
- * %eax contains the semaphore pointer on entry. Save the C-clobbered
- * registers (%eax, %edx and %ecx) except %eax which is either a return
- * value or just gets clobbered. Same is true for %edx so make sure GCC
- * reloads it after the slow path, by making it hold a temporary, for
- * example see ____down_write().
- */
-
-#define save_common_regs \
-	pushl %ecx
-
-#define restore_common_regs \
-	popl %ecx
-
-	/* Avoid uglifying the argument copying x86-64 needs to do. */
-	.macro movq src, dst
-	.endm
-
-#else
-
-/*
- * x86-64 rwsem wrappers
- *
- * This interfaces the inline asm code to the slow-path
- * C routines. We need to save the call-clobbered regs
- * that the asm does not mark as clobbered, and move the
- * argument from %rax to %rdi.
- *
- * NOTE! We don't need to save %rax, because the functions
- * will always return the semaphore pointer in %rax (which
- * is also the input argument to these helpers)
- *
- * The following can clobber %rdx because the asm clobbers it:
- *   call_rwsem_down_write_failed
- *   call_rwsem_wake
- * but %rdi, %rsi, %rcx, %r8-r11 always need saving.
- */
-
-#define save_common_regs \
-	pushq %rdi; \
-	pushq %rsi; \
-	pushq %rcx; \
-	pushq %r8;  \
-	pushq %r9;  \
-	pushq %r10; \
-	pushq %r11
-
-#define restore_common_regs \
-	popq %r11; \
-	popq %r10; \
-	popq %r9; \
-	popq %r8; \
-	popq %rcx; \
-	popq %rsi; \
-	popq %rdi
-
-#endif
-
-/* Fix up special calling conventions */
-ENTRY(call_rwsem_down_read_failed)
-	FRAME_BEGIN
-	save_common_regs
-	__ASM_SIZE(push,) %__ASM_REG(dx)
-	movq %rax,%rdi
-	call rwsem_down_read_failed
-	__ASM_SIZE(pop,) %__ASM_REG(dx)
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_read_failed)
-
-ENTRY(call_rwsem_down_write_failed)
-	FRAME_BEGIN
-	save_common_regs
-	movq %rax,%rdi
-	call rwsem_down_write_failed
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_write_failed)
-
-ENTRY(call_rwsem_down_write_failed_killable)
-	FRAME_BEGIN
-	save_common_regs
-	movq %rax,%rdi
-	call rwsem_down_write_failed_killable
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_write_failed_killable)
-
-ENTRY(call_rwsem_wake)
-	FRAME_BEGIN
-	/* do nothing if still outstanding active readers */
-	__ASM_HALF_SIZE(dec) %__ASM_HALF_REG(dx)
-	jnz 1f
-	save_common_regs
-	movq %rax,%rdi
-	call rwsem_wake
-	restore_common_regs
-1:	FRAME_END
-	ret
-ENDPROC(call_rwsem_wake)
-
-ENTRY(call_rwsem_downgrade_wake)
-	FRAME_BEGIN
-	save_common_regs
-	__ASM_SIZE(push,) %__ASM_REG(dx)
-	movq %rax,%rdi
-	call rwsem_downgrade_wake
-	__ASM_SIZE(pop,) %__ASM_REG(dx)
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_downgrade_wake)
