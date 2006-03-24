From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 24 Mar 2006 15:18:11 +0000
Subject: unlock_buffer() and clear_bit()
Message-Id: <44240DB3.3040502@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I wonder if "unlock_buffer()" works correctly on ia64...

As far As I can see, nothing makes it sure that data modifications
issued inside the critical section be globally visible before the
"BH_Lock" bit gets cleared.

- Either an "smp_mb__before_clear_bit()" is lacking
  (if we want to keep the existing definition of "clear_bit()"
   with its "acq" semantics)

- or "clear_bit()" should use the "rel" semantics
  (since we are actually _releasing_ a lock)

Thanks,

Zoltan Menyhart



buffer.c:

void fastcall unlock_buffer(struct buffer_head *bh)
{
	clear_buffer_locked(bh);
	smp_mb__after_clear_bit();
	wake_up_bit(&bh->b_state, BH_Lock);
}


asm-ia64/bitops.h:

/*
 * clear_bit() has "acquire" semantics.
 */
#define smp_mb__before_clear_bit()	smp_mb()
#define smp_mb__after_clear_bit()	do { /* skip */; } while (0)

/**
 * clear_bit - Clears a bit in memory
 * @nr: Bit to clear
 * @addr: Address to start counting from
 *
 * clear_bit() is atomic and may not be reordered.  However, it does
 * not contain a memory barrier, so if it is used for locking purposes,
 * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
 * in order to ensure changes are visible on other processors.
 */


