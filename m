From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Sep 2003 06:57:19 +0000
Subject: 2.6 mca_asm.S VA to PA mappings
Message-Id: <marc-linux-ia64-106490506400881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.6.0-test5-ia64-030908, arch/ia64/kernel/mca_asm.S, ia64_os_mca_done_dump
sets r2 to ia64_mca_bspstore then does DATA_VA_TO_PA(r2) which uses tpa.
This is before MCA has checked for a tlb error.  Is it safe to use tpa
before checking that the tlb data is valid or should it be using
LOAD_PHYSICAL?

Before calling the C code, MCA uses VIRTUAL_MODE_ENTER which in turn
calls DATA_PA_TO_VA on ar.bspstore.  DATA_PA_TO_VA sets bits 61:63 to
1, which assumes that ar.bspstore is identity mapped.  On a
non-identity mapped 2.4 kernel I have seen ar.bspstore go

ia64_mca_bspstore	(V=0xe000000004d5a6d0)
DATA_VA_TO_PA		(P=0x0000013014d5a6d0)
DATA_PA_TO_VA		(V=0xe000013014d5a6d0)

With the 2.4 alt.dtlb handler that still works, although it is
confusing to C code which needs to access the RSE data in
ia64_mca_bspstore.  I doubt that DATA_PA_TO_VA will work if the kernel
is in region 5.

