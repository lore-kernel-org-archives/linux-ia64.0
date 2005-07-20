From: James E Wilson <wilson@tuliptree.org>
Date: Wed, 20 Jul 2005 22:34:16 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <1121898856.27487.44.camel@aretha.corp.specifix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-07-19 at 22:31, Ian Wienand wrote:
> After some investigation I believe this is do with differences between
> the alignment of variables on the stack between gcc 3 and 4 and the
> ski simulator.

There has been no change to the natural alignment for the variable
here.  It has always been 4 bytes.  There has been a change to the
placement of variables into stack slots.  This stuff was completely
written as part of the tree-ssa work.

If gcc-3.4 and earlier, some structures (BLKmode structures) were being
over-aligned when allocated to stack slots.  They always got the maximum
alignment (16 bytes for IA-64) instead of their natural alignment.  It
isn't clear why.  I think this was an accident of implementation.  We
were basing variable alignment on modes instead of type alignment, and
since some BLKmode structures do require max alignment, we had to give
it to all of them.

In gcc-4.0, we get this right.  The variable/type alignment is used to
determine the stack alignment needed.  If the alignment is less than the
stack slot size, then we don't pad to the next stack slot regardless of
the size or type or mode of the variable.  We only pad to the alignment
boundary.  This results in smaller frame sizes.  In this case though, we
end up with the structure being allocated across two stack slots, even
though it would fit in one.  Again, I think this is an accident of
implementation.  We might get better code if this structure was
allocated to a single stack slot, as then we could use ld8/st8 to move
it around.  This would be at the expense of a small increase in frame
size in general, though we would still have smaller frames than gcc-3.4
and earlier.  Probably no one has considered this issue because no one
has noticed it before.


