From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 27 Sep 2009 05:20:32 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E2DD4A5E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just for reference ... here is what gcc produces from the
code that I submitted for spin_lock (the spin_unlock gets
inlined as a single fetchadd4.rel):

a000000100805100 <_spin_lock>:
a000000100805100:       [MMI]       mov r2=r32;;
a000000100805106:                   ld4 r15=[r2],4
a00000010080510c:                   nop.i 0x0;;
a000000100805110:       [MII]       fetchadd4.acq r14=[r2],1
a000000100805116:                   nop.i 0x0
a00000010080511c:                   nop.i 0x0;;
a000000100805120:       [MIB]       mov r16=r14
a000000100805126:                   cmp4.eq p6,p7=r15,r14
a00000010080512c:             (p06) br.ret.dpnt.many b0
a000000100805130:       [MII]       hint.m 0x0
a000000100805136:                   nop.i 0x0
a00000010080513c:                   nop.i 0x0;;
a000000100805140:       [MMI]       nop.m 0x0
a000000100805146:                   ld4.acq r3=[r32]
a00000010080514c:                   nop.i 0x0;;
a000000100805150:       [MIB]       nop.m 0x0
a000000100805156:                   cmp4.eq p9,p8=r16,r3
a00000010080515c:             (p08) br.cond.dptk.few a000000100805130 <_spin_lock+0x30>
a000000100805160:       [MIB]       nop.m 0x0
a000000100805166:                   nop.i 0x0
a00000010080516c:                   br.ret.sptk.many b0;;

As I said, I ran this past a h/w guru who blessed its semantics
(while griping a little about some of the dumbness of gcc). He's
looking into whether we can improve the contended case using
ld4.c.nc (ia64 equivalent of mwait) to stall until the "now-serving"
value actually changes, rather than keep peeking at it.

I'll take a look at the performance of the 4-byte version of the lock
to see how it stacks up.  If that doesn't come out well, I can look
at improving the "ld4" ... "fetchadd4" cache transition issue that
you first complained about.

-Tony
