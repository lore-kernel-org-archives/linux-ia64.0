From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Feb 2005 05:38:07 +0000
Subject: Re: Make MCA stack look like a normal kernel stack
Message-Id: <16906.62271.997281.29000@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10372.1107999173@kao2.melbourne.sgi.com>
In-Reply-To: <10372.1107999173@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 Feb 2005 13:47:47 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The problem is that some of the dirty registers will be in
  Keith> the original stack, some will be in the MCA stack.

That's OK, libunwind already handles that.  The only thing that's
needed to make this work is that ar.bsp/ar.bspstore/ar.rnat are saved
and that those saves properly be described by the unwind-info.  The
rest will be automatic.  There is one problem though: in pt_regs, we
save the loadrs value instead of ar.bsp.  That can't be described at
the moment (the pt_regs code was written long before I knew about
unwind-info...).  However, since pt_regs is special anyhow, we can
just handle that in the unwinder, analogous to what we do for
signal-handlers (check_rbs_switch() in libunwind's src/ia64/Gstep.c).

  Keith> The preserved registers at the time of MCA/INIT still need to
  Keith> be saved so they can be restored on return to SAL.  Save the
  Keith> preserved registers, set the values that the kernel needs,
  Keith> call C code, restore original preserved registers, return to
  Keith> SAL.  Hmm, I just described struct switch_stack, didn't I?

True.  If you really return, then there is no need to even use switch_stack.
You'd just return and that magically restores the preserved registers.

	--david
