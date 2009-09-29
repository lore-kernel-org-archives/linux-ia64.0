From: Tejun Heo <teheo@suse.de>
Date: Tue, 29 Sep 2009 00:25:14 +0000
Subject: Re: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic percpu
Message-Id: <4AC153EA.2050007@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org>
In-Reply-To: <1253682382-24740-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org

Tejun Heo wrote:
> Hello, all.
> 
> This is the second take of convert-ia64-to-dynamic-percpu patchset.
> Changes from the last take[L] are
> 
> * 0001 now updates ia64 to not define VMALLOC_END as a macro to
>   vmalloc_end instead of disallowing vmalloc_end as a variable name as
>   suggested by Christoph.
> 
> * 0002 added to initialize cpu maps early.  This is necessary to get
>   contig memory model working.
> 
> * 0004 updated so that dyn_size is calculated correctly for contig
>   model.
> 
> This patchset contains the following five patches.
> 
>  0001-ia64-don-t-alias-VMALLOC_END-to-vmalloc_end.patch
>  0002-ia64-initialize-cpu-maps-early.patch
>  0003-ia64-allocate-percpu-area-for-cpu0-like-percpu-areas.patch
>  0004-ia64-convert-to-dynamic-percpu-allocator.patch
>  0005-percpu-kill-legacy-percpu-allocator.patch
> 
> 0001 is misc prep to avoid macro / local variable collision.  0002
> makes ia64 arch code initialize cpu possible and present maps before
> memory initialization.  0003 makes ia64 allocate percpu area for cpu0
> in the same way it does for other cpus.  0004 converts ia64 to dynamic
> percpu allocator and 0005 drops now unused legacy allocator.
> 
> Contig memory model was tested on a 16p Tiger4 machine.  Discontig and
> sparse tested on 4-way SGI altix.  ski seems to be happy with contig
> up/smp.
> 
> This patchset is available in the following git tree.
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git convert-ia64
> 
> The new commit ID is dcc91f19c6662b24f1f4e5878d773244f1079724 and it's
> on top of today's Linus 7fa07729e439a6184bd824746d06a49cca553f15.

Tony, can you please ack ia64 part?

Thanks.

-- 
tejun
