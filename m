From: John Keller <jpk@sgi.com>
Date: Tue, 25 Nov 2008 20:50:01 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <200811252050.mAPKo2CL087992@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20081123143722.03dbbfcc@kopernikus.site> from "Bernhard Walle" at Nov 23, 2008 02:37:22 PM
References: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> 
> Hi,
> 
> [Sorry for the late reply and for not following the whole thread, I'm
> just busy.]
> 
> * John Keller [2008-11-18 08:08]:
> > 
> > This patch addresses a problem on SN Altix systems with < 4GB, where
> > device drivers using the dma_get_required_mask() API would be told
> > to use 32 bit DMA, when 64 bit is more efficient.
> > 
> > How exactly the use of dma_get_required_mask() relates to the crash
> > kernel code you refer to is unclear to me.
> 
> I'm not sure myself. The crashkernel reservation code on IA64 (for
> other architectures I don't know any machines that have basically their
> whole memory except a small amount which is used for booting mapped
> above 4 GiB physical address space) needs to check if it's okay to
> use memory for the crashkernel that is *all* above 4 GiB.
> 
> This is only possible if a hardware IO/MMU is present (and working
> correctly in the kdump case which isn't the case on HP IA64) and SWIOTBL
> is not used because SWIOTBL needs some memory below that 4 GiB margin.
> 
> Now I thought that there's a relationship between "memory above 4 GiB
> can be used for DMA" and the return value of dma_get_required_mask().
> My assumption was:
> 
>   (dma_get_required_mask() & 0xffffffff00000000ull) > 0
>   -> memory above 4 GiB can be used for DMA and so the
>      crashkernel memory can reside above 4 GiB
> 
>   (dma_get_required_mask() & 0xffffffff00000000ull) = 0
>   -> memory above 4 GiB can not be used for DMA and so the
>      crashkernel memory can not all reside above 4 GiB
> 
> Is that wrong?

In the case of SN Altix, the return value (with my patch) will always
be 0xffffffffffffffffull. So, your check would work. And just as the
current code's ia64_platform_is("sn2") check would always return TRUE
on any SN2 system, so would your proposed use of dma_get_required_mask().

However, for SN2, memory size or location cannot be inferred from the
return value, as it has no affect on the returned value.
As Documentation/DMA-API.txt says:
    "This API returns the mask that the platform requires to
    operate efficiently."

And for SN2, this is always a 64 bit mask, irregardless of memory size,
location, etc.


> 
> > If, for all platforms, the crash kernel code could use the mask returned
> > from dma_get_required_mask() to do its check, then switching the code
> > might be OK. But, if that's not possible for some platforms, then I'd
> > wonder if dma_get_required_mask() is being used in the wrong context in
> > this case.
> 
> The crashkernel reservation code is different for every platform, so it
> does not matter. However, in theory I think the check would return
> correct results.

OK, I must not be understanding something. check_crashkernel_memory()
appears to be coded to handle 3 or more platforms (sn2, uv, and others).


> 
> 
> Regards,
> Bernhard
> -- 
> Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
> 

