From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 Dec 2005 13:20:19 +0000
Subject: Re: [patch 2.6.15-rc5] Define an ia64 version of __raw_read_trylock
Message-Id: <11724.1134393619@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17916.1134185068@ocs3.ocs.com.au>
In-Reply-To: <17916.1134185068@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 12 Dec 2005 14:16:29 +0800, 
Zou Nan hai <nanhai.zou@intel.com> wrote:
>On Sat, 2005-12-10 at 11:24, Keith Owens wrote:
>> IA64 is using the generic version of __raw_read_trylock, which always
>> waits for the lock to be free instead of returning when the lock is in
>> use.  Define an ia64 version of __raw_read_trylock which behaves
>> correctly, and drop the generic one.
>> 
>> Signed-off-by: Keith Owens <kaos@sgi.com>
>> 
>> Index: linux/include/asm-ia64/spinlock.h
>> =================================>> --- linux.orig/include/asm-ia64/spinlock.h      2005-12-09
>> 14:44:56.883252331 +1100
>> +++ linux/include/asm-ia64/spinlock.h   2005-12-10 14:20:44.459423430
>> +1100
>> @@ -201,6 +201,16 @@ static inline void __raw_write_unlock(ra
>>  
>>  #endif /* !ASM_SUPPORTED */
>>  
>> -#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
>> +static inline int __raw_read_trylock(raw_rwlock_t *x)
>> +{
>> +       union {
>> +               raw_rwlock_t lock;
>> +               __u32 word;
>> +       } old, new;
>> +       old.lock = new.lock = *x;
>> +       old.lock.write_lock = new.lock.write_lock = 0;
>> +       ++new.lock.read_counter;
>> +       return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word,
>> old.word) = old.word;
>> +}
>>  
>>  #endif /*  _ASM_IA64_SPINLOCK_H */
>> 
>
>   How about using fetchadd4.acq 1 in trylock and rollback by fetchadd4.rel -1 if lock failed, 
>just like how __raw_read_lock does?
>   That should emit fewer code and give no extra memory foot print I think.

The code generated for the patch requires no extra memory, the old and
new variables are optimized to registers.

0000000000000000 <_raw_read_trylock>:
   0:   05 58 00 40 10 d0       [MLX]       ld4 r11=[r32]
   6:   7f 00 00 00 00 20                   movl r9=0x7fffffff;;
   c:   f1 f7 ff 67
  10:   0b 18 24 16 0c 20       [MMI]       and r3=r9,r11;;
  16:   a0 08 0c 00 42 00                   adds r10=1,r3
  1c:   00 00 04 00                         nop.i 0x0;;
  20:   00 40 28 12 0c 20       [MII]       and r8=r10,r9
  26:   00 00 00 02 00 00                   nop.i 0x0
  2c:   00 00 04 00                         nop.i 0x0
  30:   0b 00 0c 40 2a 04       [MMI]       mov.m ar.ccv=r3;;
  36:   20 40 80 22 20 00                   cmpxchg4.acq r2=[r32],r8,ar.ccv
  3c:   00 00 04 00                         nop.i 0x0;;
  40:   1d 40 08 06 89 38       [MFB]       cmp4.eq p8,p9=r2,r3
  46:   00 00 00 02 00 00                   nop.f 0x0
  4c:   00 00 00 20                         nop.b 0x0;;
  50:   11 41 04 00 00 64       [MIB] (p08) mov r8=1
  56:   82 00 00 00 42 80             (p09) mov r8=r0
  5c:   08 00 84 00                         br.ret.sptk.many b0;;

The code with fetchadd is one bundle less, but it requires an extra
memory update and possible cache line bounce when the lock is
contended.  We are talking about micro optmizations here so I doubt
that the difference is measurable, but my gut says that an extra memory
update in the contention case is (in general) the wrong approach.

00000000000007e0 <_raw_read_trylock>:
 7e0:   0e 10 0c 40 91 10       [MMF]       fetchadd4.acq r2=[r32],1
 7e6:   00 00 00 02 00 00                   nop.m 0x0
 7ec:   00 00 04 00                         nop.f 0x0
 7f0:   1d 40 04 00 00 24       [MFB]       mov r8=1
 7f6:   00 00 00 02 00 00                   nop.f 0x0
 7fc:   00 00 00 20                         nop.b 0x0;;
 800:   11 40 08 00 89 30       [MIB]       cmp4.lt p8,p9=r2,r0
 806:   00 00 00 02 80 84                   nop.i 0x0
 80c:   08 00 84 02                   (p09) br.ret.dptk.many b0;;
 810:   00 70 1c 40 b1 10       [MII]       fetchadd4.rel r14=[r32],-1
 816:   00 00 00 02 00 00                   nop.i 0x0
 81c:   00 00 04 00                         nop.i 0x0
 820:   11 40 00 00 00 21       [MIB]       mov r8=r0
 826:   00 00 00 02 00 80                   nop.i 0x0
 82c:   08 00 84 00                         br.ret.sptk.many b0;;

Index: linux/include/asm-ia64/spinlock.h
=================================--- linux.orig/include/asm-ia64/spinlock.h	2005-12-10 19:50:34.001197292 +1100
+++ linux/include/asm-ia64/spinlock.h	2005-12-13 00:12:47.250022120 +1100
@@ -201,6 +201,12 @@ static inline void __raw_write_unlock(ra
 
 #endif /* !ASM_SUPPORTED */
 
-#define __raw_read_trylock(lock) generic__raw_read_trylock(lock)
+static inline int __raw_read_trylock(raw_rwlock_t *x)
+{
+	if (likely(ia64_fetchadd(1, (int *) x, acq) >= 0))
+		return 1;
+	ia64_fetchadd(-1, (int *) x, rel);
+	return 0;
+}
 
 #endif /*  _ASM_IA64_SPINLOCK_H */

