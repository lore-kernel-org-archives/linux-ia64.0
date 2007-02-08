From: Horms <horms@verge.net.au>
Date: Thu, 08 Feb 2007 03:06:53 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <20070208030651.GA29670@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 08, 2007 at 10:07:48AM +0800, Zou, Nanhai wrote:
> 
> Hi Vivek,
> 	I have a question about why saved_max_pfn check in vmcore.c is needed.
> Here is a typical memory layout of IA64 machine.
> 
> ----- ==>max_pfn for first kernel
> 	 the first kernel
> ----- ==>max_pfn for crash dump kernel
> the crash dump kernel
> -----	
> the first kernel
> ----- 
> 
> When crash dump kernel tries to access memory of first kernel above
> saved_max_pfn of him, read_from_oldmem will refuse that read.
> 
> That result an empty vmcore file. change saved_max_pfn to unsigned
> long(-1) will fix this issue.
> 
> However since memory ranges in vmcore is pre defined from /proc/iomem
> of first kernel, why do we still need to add an extra check in
> vmcore.c

Hi Nan-hai,

sorry that I did not get back to you about the information you requested
about my system, I guess you have managed to reproduce the problem none
the less.

I can confirm that removing the max_pfn check in vmcore.c does
indeed give /proc/vmcore a non-zero (and presumably correct) size.

I wonder if the problem is that saved_max_pfn is being incorectly
calculated on ia64. That it is being set to the max_pfn of the
crash kernel (i.e. in the crashkernel=X@Y area), rather than
the max_pfn of the physical memory of the system, which seems
more sensible as the purpose of vmcore is to read memory
outside of the crashkernel=X@Y area.

You may be right that we can just remove the check all together,
though perhaps it is there for the case where the range information
in the vmcode are corrupted. Then again, should we care about this?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

