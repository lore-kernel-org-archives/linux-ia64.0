From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Jun 2004 05:29:08 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <16605.2468.560954.201887@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 Jun 2004 09:31:15 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Regarding to rev 1.24 in head.S:
  Ken> http://lia64.bkbits.net:8080/linux-ia64-2.5/diffs/arch/ia64/kernel/head.S@1.24?nav=index.html|src/.|src/arch|src/arch/ia64|src/arch/
  Ken> ia64/kernel|hist/arch/ia64/kernel/head.S

  Ken> The relocation of r16 is incorrect.  For BP, we are not installing any
  Ken> region 7 TLB mapping.

Indeed!  I must be missing something though: with your patch, r13 will
be initialized to the region 7 address again, which defeats the
purpose of the original patch.  I think the initialization of r13
needs to be conditional on whether we're dealing with init_task or
anything else.

  Ken> As explained earlier, BP did a call to efi_call_phys which
  Ken> switches to physical mode and then back to virtual.  When going
  Ken> back to virtual, it converts ar.bspstore and sp to region 7
  Ken> address.  After that, any heavy weight fault will lead into
  Ken> nested fault because there are no region 7 dtlb mapping for its
  Ken> stack.  The fix is to special case ia64_switch_mode_virt to
  Ken> compute ar.bspstore and sp's virtual addresses into region 5.

True, but it's really ugly to add more special cases.  Wouldn't it be
better to explicitly pass the sp/bsp that need to be restored?
(Caveat: can't use the normal calling conventions there; perhaps r17
and r18 could be used?)

	--david
