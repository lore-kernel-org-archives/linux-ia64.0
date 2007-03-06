From: Horms <horms@verge.net.au>
Date: Tue, 06 Mar 2007 07:34:51 +0000
Subject: Re: Crash Dump Region
Message-Id: <20070306073450.GA20205@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306015655.GA27129@verge.net.au>
In-Reply-To: <20070306015655.GA27129@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 06, 2007 at 10:32:09AM +0800, Zou Nan hai wrote:
> On Tue, 2007-03-06 at 09:56, Horms wrote:
> > Hi,
> > 
> > I am currently looking over the code that places the crashdump
> > region into /proc/iomem, and the code that determines its base
> > address if it is not passed on the kernel comamnd. It seems to me that
> > the current code allows the crashkernel to be placed incide a
> > /proc/iomem region of any type. Is this behaviour correct?
> > If not, should it be restricted to "System RAM" regions?
> 
> Please review the patch.

This looks good to me.

Acked-by: Simon Horman <horms@verge.net.au>

> Thanks
> Zou Nan hai
> 
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
> 
> --- a/arch/ia64/kernel/efi.c	2007-02-27 00:42:06.000000000 -0500
> +++ b/arch/ia64/kernel/efi.c	2007-03-05 22:09:40.000000000 -0500
> @@ -1154,7 +1154,7 @@ kdump_find_rsvd_region (unsigned long si
>  
>    for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
>  	  md = p;
> -	  if (!efi_wb(md))
> +	  if (!is_memory_available(md))
>  		  continue;
>  	  start = ALIGN(md->phys_addr, alignment);
>  	  end = efi_md_end(md);
> 
> 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

