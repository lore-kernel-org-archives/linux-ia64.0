From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Jun 2004 05:55:21 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <16605.4041.223070.440847@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 25 Jun 2004 22:48:26 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> David Mosberger wrote on Friday, June 25, 2004 10:29 PM

  Ken> The relocation of r16 is incorrect.  For BP, we are not installing any
  Ken> region 7 TLB mapping.

  >> Indeed!  I must be missing something though: with your patch, r13 will
  >> be initialized to the region 7 address again, which defeats the
  >> purpose of the original patch.  I think the initialization of r13
  >> needs to be conditional on whether we're dealing with init_task or
  >> anything else.

  Ken> Not sure what you mean.  The first two hunks are trying to revert the
  Ken> change in rev 1.24 and r16 initialization, which gets put into kr(stack)
  Ken> later. I'm not touching r13.

Ah, yes, my bad (I guess I really should catch up sleep first...).

  >> True, but it's really ugly to add more special cases.  Wouldn't it be
  >> better to explicitly pass the sp/bsp that need to be restored?
  >> (Caveat: can't use the normal calling conventions there; perhaps r17
  >> and r18 could be used?)

  Ken> Yeah, but we have to update all the call sites, current efi_call_phys
  Ken> and two other PAL static/stacked calls.

True, but I think there are only 3 call-sites.  If it turns out to be
_really_ ugly we can reonsider, but I think it might be a better
choice in the long run.

	--david
