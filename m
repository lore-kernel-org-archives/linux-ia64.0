From: Robin Holt <holt@sgi.com>
Date: Sat, 26 Feb 2005 14:33:16 +0000
Subject: Re: [Patch 0/3] Page Table Fixups.
Message-Id: <20050226143316.GH10965@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142250.GB10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142250.GB10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

I originally meant to send these three to you as well
for inclusion.  Do you want me to repost all of the messages
or can you pick them up from the mailing list?

I decided to not do the zero slab allocator because introducing
node awareness seemed to be a very daunting task and others at
SGI are already planning work in that area.  With the third patch
in this set, the need for a node aware slab allocator becomes
less important as quicklist size is shrunk based upon free
memory in the system.  This happens from either cpu idle or
from tlb_finish_mmu(), which seems to be often enough.

Any comments or concerns are welcome.

Thanks,
Robin Holt


On Sat, Feb 26, 2005 at 08:22:50AM -0600, Robin Holt wrote:
> 
> The following set of patches gets the page table code to
> the same condition that the SGI internal kernel has been
> for some time.  The set consists of three patches.
> 
> 1) Ensure pgd, pmd, and pte entries get returned to quicklists.
> 2) If CONFIG_NUMA is set, free pages from other nodes instead
>    of placing them on our quicklist.
> 3) Shrink quicklists based upon free memory.
> 
> I have run lmbench on these and did not notice a significant
> change on anything other than the lat_proc set of tests.
> These all show improvements.
> 
> For fork+exit and fork+execve, I saw consistent speedups.  Individual
> run data is included with each patch.
> 
> During the lat_proc runs, there is not enough memory pressure to
> force quicklist tossing and therefore the last set of numbers
> appears to be completely in the noise range for the test.
> 
> These patches are against Linus' 2.6.11-rc5 tree.
> 
> Thanks,
> Robin Holt
> 
> Signed-off-by: Robin Holt <holt@sgi.com>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
