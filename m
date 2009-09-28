From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Sep 2009 22:35:27 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <4ac13a2f28573cec9e@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here are the source and disassembled binary for the lock/unlock
routines modified as suggested by Linus to fit the lock word
back into 32-bits.

Performance for lock/unlock time in the uncontended in-cache case
is a little worse (another 8% on top of the 8% I'd already given
up compared to the original "xchg" version).  I haven't tried a
macro-level benchmark yet to see whether this makes it noticeable.

-Tony

#define TICKET_SHIFT	17
#define TICKET_BITS	15

static __always_inline void __ticket_spin_lock(raw_spinlock_t *lock)
{
	int	*p = (int *)&lock->lock, ticket, serve;

	ticket = ia64_fetchadd(1, p, acq);

	if (!(((ticket >> TICKET_SHIFT) ^ ticket) & ((1L << TICKET_BITS) - 1)))
		return;

	do {
		cpu_relax();
		serve = ACCESS_ONCE(*p);
	} while (((serve >> TICKET_SHIFT) ^ ticket) & ((1 << TICKET_BITS) - 1));
}

a000000100815d00 <_spin_lock>:
a000000100815d00:       [MII]       fetchadd4.acq r14=[r32],1
a000000100815d06:                   nop.i 0x0
a000000100815d0c:                   nop.i 0x0;;
a000000100815d10:       [MII]       nop.m 0x0
a000000100815d16:                   extr r3=r14,17,15
a000000100815d1c:                   mov r172767
a000000100815d20:       [MMI]       mov r16=r14;;
a000000100815d26:                   xor r2=r14,r3
a000000100815d2c:                   nop.i 0x0;;
a000000100815d30:       [MII]       nop.m 0x0
a000000100815d36:                   extr.u r15=r2,0,15;;
a000000100815d3c:                   nop.i 0x0
a000000100815d40:       [MMB]       cmp.eq p6,p7=0,r15
a000000100815d46:                   nop.m 0x0
a000000100815d4c:             (p06) br.ret.dpnt.many b0
a000000100815d50:       [MMI]       hint.m 0x0
a000000100815d56:                   nop.m 0x0
a000000100815d5c:                   nop.i 0x0;;
a000000100815d60:       [MMI]       ld4.acq r11=[r32];;
a000000100815d66:                   nop.m 0x0
a000000100815d6c:                   extr r10=r11,17,15;;
a000000100815d70:       [MMI]       xor r9=r16,r10;;
a000000100815d76:                   and r8=r17,r9
a000000100815d7c:                   nop.i 0x0;;
a000000100815d80:       [MIB]       nop.m 0x0
a000000100815d86:                   cmp4.eq p9,p8=0,r8
a000000100815d8c:             (p08) br.cond.dptk.few a000000100815d50 <_spin_lock+0x50>
a000000100815d90:       [MIB]       nop.m 0x0
a000000100815d96:                   nop.i 0x0
a000000100815d9c:                   br.ret.sptk.many b0;;

static __always_inline void __ticket_spin_unlock(raw_spinlock_t *lock)
{
	unsigned short	*p = (unsigned short *)&lock->lock + 1, tmp;

	asm volatile ("ld2.bias %0=[%1]" : "=r"(tmp) : "r"(p));
	ACCESS_ONCE(*p) = (tmp + 2) & ~1;
}

a00000010000a4a0:       [MII]       mov r36e534
...
a00000010000a4d0:       [MII]       ld2.bias r9=[r34]
a00000010000a4d6:                   nop.i 0x0
a00000010000a4dc:                   nop.i 0x0;;
a00000010000a4e0:       [MMI]       adds r8=2,r9;;
a00000010000a4e6:                   and r3=r36,r8
a00000010000a4ec:                   nop.i 0x0
a00000010000a4f0:       [MMI]       nop.m 0x0;;
a00000010000a4f6:                   st2.rel [r34]=r3

