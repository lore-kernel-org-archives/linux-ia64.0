From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Jul 2004 16:50:20 +0000
Subject: RE: [BROKEN PATCH] kexec for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01BB7505@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Jesse Barnes schrieb:
>I'm also worried about a few things in this patch.  Is 
>relocate_kernel.S really necessary in 2.6?  Can we copy
>the kernel to a contiguous 64MB aligned area, drop into
>phys mode and just jump to it?  

and Christian replied:
>You should be safe with that but you should consider flushing TLB 
>entries of the old kernel before the newly started kernel inserts its 
>own translations.

Don't just "consider" it ... this is essential or you will take
MCA when you try to install overlapping TLB entries as the new
kernel boots.  Luckily all the code you need to do this already
exists in the MCA-TLB recovery code in mca_asm.S (so long as you
think that you can trust the 'ia64_mca_tlb_list' has not been
corrupted).

-Tony
