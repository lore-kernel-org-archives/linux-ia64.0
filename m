From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 09 Feb 2004 18:02:57 +0000
Subject: RE: mca.c: Incorrect recovery from TLB errors?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F4FB16C@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <2848.1076291608@kao2.melbourne.sgi.com>
In-Reply-To: <2848.1076291608@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> In both 2.4 and 2.6 kernels, arch/ia64/kernel/mca.c
> ia64_return_to_sal_check() has
> 
> 	if (psp->cc = 1 && psp->bc = 1 && psp->rc = 1 && 
> psp->uc = 1)
> 		ia64_os_to_sal_handoff_state.imots_os_status = 
> IA64_MCA_COLD_BOOT;
> 	else
> 		ia64_os_to_sal_handoff_state.imots_os_status = 
> IA64_MCA_CORRECTED;
> 
> Why does it test for all the cc/bc/rc/uc bits being set?  Surely that
> should be or, not and?  The real test for recovery is
> 
> 	psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc)

Oops!  My code is totally bogus ... yours looks a whole lot better.

> The existing code is also inconsistent with the test in 
> mca_asm.S, that
> only tests for psp->tc being 1 and ignores the other bits.

I don't think that is inconsistent ... just incomplete.  The
"tc" error is going to be the only one that is recovered in
mca_asm.S ... we have to do it there because we can't go into
virtual mode until we know that the ITR/DTR are correct.  Some
day there will be other MCA recoveries, but they should happen
in C code called from mca.c
 
> Tony: it makes life easier for kdb if the "am I going to recover" test
> is promoted from ia64_return_to_sal_check() to ia64_mca_ucmc_handler()
> and passed down to ia64_return_to_sal_check().  Otherwise kdb has to
> duplicate the code in ia64_return_to_sal_check() to decide if the MCA
> is recoverable or not, normally you do not want kdb to handle a
> recovered error.  Any objections to this?
> 
> void
> ia64_mca_ucmc_handler(void)
> {
> 	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
> 		&ia64_sal_to_os_handoff_state.proc_state_param;
> 	int recover = psp->tc && !(psp->cc || psp->bc || 
> psp->rc || psp->uc);
> 	...
> 	ia64_return_to_sal_check(psp, recover)
> }

Looks clean ... and if it makes your life easier, and avoids
duplicating this test, then go for it.  This test for "did we
recover" is likely to see a lot of changes as more recovery cases
are added ... so avoiding duplicating it will make maintenance
easier as time goes by.

-Tony
