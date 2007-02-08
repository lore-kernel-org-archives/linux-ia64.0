From: Vivek Goyal <vgoyal@in.ibm.com>
Date: Thu, 08 Feb 2007 05:46:52 +0000
Subject: Re: Zero size /proc/vmcore on ia64
Message-Id: <20070208053452.GC5997@in.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 08, 2007 at 12:06:53PM +0900, Horms wrote:
> On Thu, Feb 08, 2007 at 10:07:48AM +0800, Zou, Nanhai wrote:
> > 
> > Hi Vivek,
> > 	I have a question about why saved_max_pfn check in vmcore.c is needed.
> > Here is a typical memory layout of IA64 machine.
> > 
> > ----- ==>max_pfn for first kernel
> > 	 the first kernel
> > ----- ==>max_pfn for crash dump kernel
> > the crash dump kernel
> > -----	
> > the first kernel
> > ----- 
> > 
> > When crash dump kernel tries to access memory of first kernel above
> > saved_max_pfn of him, read_from_oldmem will refuse that read.
> > 
> > That result an empty vmcore file. change saved_max_pfn to unsigned
> > long(-1) will fix this issue.
> > 
> > However since memory ranges in vmcore is pre defined from /proc/iomem
> > of first kernel, why do we still need to add an extra check in
> > vmcore.c
> 
> Hi Nan-hai,
> 
> sorry that I did not get back to you about the information you requested
> about my system, I guess you have managed to reproduce the problem none
> the less.
> 
> I can confirm that removing the max_pfn check in vmcore.c does
> indeed give /proc/vmcore a non-zero (and presumably correct) size.
> 
> I wonder if the problem is that saved_max_pfn is being incorectly
> calculated on ia64. That it is being set to the max_pfn of the
> crash kernel (i.e. in the crashkernel=X@Y area), rather than
> the max_pfn of the physical memory of the system, which seems
> more sensible as the purpose of vmcore is to read memory
> outside of the crashkernel=X@Y area.
> 

Hi Horms/Nan-hai,

Horms, you are right. saved_max_pfn is needed to know that second kernel
is not trying to read any memory which is not present or was not being
used by the crashed kernel at all. That's why in i386/x86_64, during
early boot saved_max_pfn, is calculated the memory map passed to the second
kernel. This memory map is passed to second kernel by kexec through parameter
segment. So effectively saved_max_pfn will be set to max_pfn of crashed kernel.

Now this memory map is overwritten with user defined one which is basically
the memory second kernel can use to boot and max_pfn now will be maximum
pfn crash kernel can use.

> You may be right that we can just remove the check all together,
> though perhaps it is there for the case where the range information
> in the vmcode are corrupted. Then again, should we care about this?

I think we should not remove this check because even to parse the info
passed in ELF headers, you need to first read the ELF headers from crashed
kernel's memory. So if some programming error has passed wrong location of
ELF headers (elfcoreheader= invalid location) then we might try reading the
elf header from a non-existing physical page frame.

So the right way should be to set saved_max_pfn with right value before it
is memory map is over-written with user defined memory map.

Thanks
Vivek

