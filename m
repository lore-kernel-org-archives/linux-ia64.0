From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Sep 2003 15:42:10 +0000
Subject: RE: 2.6 mca_asm.S VA to PA mappings
Message-Id: <marc-linux-ia64-106493657330762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106490506400881@msgid-missing>
In-Reply-To: <marc-linux-ia64-106490506400881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 2.6.0-test5-ia64-030908, arch/ia64/kernel/mca_asm.S, 
> ia64_os_mca_done_dump sets r2 to ia64_mca_bspstore
> then does DATA_VA_TO_PA(r2) > which uses tpa.
> This is before MCA has checked for a tlb error.  Is it safe to use tpa
> before checking that the tlb data is valid or should it be using
> LOAD_PHYSICAL?

You are right ... if there is a TLB error, then the "tpa" may fail,
so LOAD_PHYSICAL should be used here.

> Before calling the C code, MCA uses VIRTUAL_MODE_ENTER which in turn
> calls DATA_PA_TO_VA on ar.bspstore.  DATA_PA_TO_VA sets bits 61:63 to
> 1, which assumes that ar.bspstore is identity mapped.  On a
> non-identity mapped 2.4 kernel I have seen ar.bspstore go
> 
> ia64_mca_bspstore	(V=0xe000000004d5a6d0)
> DATA_VA_TO_PA		(P=0x0000013014d5a6d0)
> DATA_PA_TO_VA		(V=0xe000013014d5a6d0)
> 
> With the 2.4 alt.dtlb handler that still works, although it is
> confusing to C code which needs to access the RSE data in
> ia64_mca_bspstore.  I doubt that DATA_PA_TO_VA will work if the kernel
> is in region 5.

Same thing, we need LOAD_PHYSICAL there too.  By the time C-code is called,
the TLB will have been repaired (all ITR/DTR entries reloaded) so the C-code
can happily use the ia64_mca_bspstore virtual address.

The new version of the MCA TLB fixup code should handle both of
these ... if I can just get it working ... I upgraded my test machine
on Friday, and now it generates MCAs all the time, not just when I
inject them :-(

-Tony
