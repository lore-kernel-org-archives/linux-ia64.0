From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 05 Aug 2008 09:54:42 +0000
Subject: Re: kdump, ia64: always reserve elfcore header memory in crash
Message-Id: <20080805025442.d4626d40.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080805094825.GA9712@verge.net.au>
In-Reply-To: <20080805094825.GA9712@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: kexec@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Tony Luck <tony.luck@intel.com>

On Tue, 5 Aug 2008 19:48:27 +1000 Simon Horman <horms@verge.net.au> wrote:

> elfcore header memory needs to be reserved in a crash kernel.
> This means that the relevant code should be protected
> by CONFIG_CRASH_DUMP rather than CONFIG_PROC_VMCORE.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> --- 
> Andrew, this patch fixes bug in the (unlikely) case where
> an ia64 crashdump kernel does not have CONFIG_PROC_FS set.
> I think it is worth including in 2.6.27. But breakage cases are
> likely to be minimal to non-existent, so I am comfortable
> with post 2.6.27 too.
> 
> This patch should be appended to the series,
> "is_kdump_kernel() cleanup and related patches".

hm, that means that we would need to apply a moderate-size seven patch
series to fix one little bug.

I think that if we want to fix this in 2.6.27 then the basic single
patch would be preferable.  Or we leave it until 2.6.28/


