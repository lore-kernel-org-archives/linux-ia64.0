From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Fri, 08 Jun 2007 02:09:25 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <BDA38860DCFD334EAEA905E44EE8E7EFC33110@G3W0067.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This of course causes problems for applications that try to use page
protection to track updates or are relying on small granularity
copy-on-write, or the like.  Anything that uses our garbage collector in
incremental mode will fit that description, though I don't believe there
are currently many such applications.  Checkpointing may be another
similar issue, at least for some applications.  Software DSM
implementations would clearly be affected.  I would guess that the trend
is likely to be towards more of this in all three of those areas.

I am not really arguing against this, since I don't have a good overview
of how many customers are likely to be affected.  I just want to make
sure that both sides of the issue are considered.

Hans

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Jack Steiner
> Sent: Thursday, June 07, 2007 6:33 PM
> To: Christoph Lameter
> Cc: tony.luck@intel.com; linux-ia64@vger.kernel.org
> Subject: Re: [IA64] Set default page size to 64k
> 
> On Thu, Jun 07, 2007 at 06:05:46PM -0700, Christoph Lameter wrote:
> > It seems that 16k page size causes Itanium processors to have 
> > significant TLB overhead when the working set is growing beyond 2M. 
> > Setting the page size to 64k reduces this problem.
> 
> At one time, there were file system issues with 64K pages. I 
> _hope_ that these have been fixed. I'll cc Dave Chinner for 
> his 2 cents. 
> 
> Note that changing the IA64 default doesn't really help 
> customers - the distros also need to change. Changing the 
> default to 64K will help determine if there are any 
> additional issues that need to be fixed.
> Distros will have more confidence in 64K if it's the default 
> in the community kernel.
> 
> 
> 
> 
> > 
> > See the paper of the researchers at the TU Dresden on TLB issues:
> > 
> http://www.cs.utah.edu/wmpi/2006/final-version/wmpi-posters-3-Juckelan
> > d.pdf
> > and my presentation
> > 
> http://ftp.kernel.org/pub/linux/kernel/people/christoph/gelato
> /gelato2007-tlb-tricks.pdf.
> > 
> > SLUB can also take advantage of the larger page sizes. A kernel 
> > compile is already ~5-10% faster with 16k. This will increase the 
> > speed even more. It will also increase the effectiveness of slab 
> > reclaim because more objects can be processed with a single 
> acquisition of the dcache or inode lock.
> > 
> > We at SGI have begun to see livelocks because of too much 
> activity on 
> > various locks. This is simply because there are too many 
> pages in the 
> > system which require frequent taking of locks. Going to 64k 
> page size 
> > will reduce the frequency of taking locks by a factor of 4.
> > 
> > IA64 systems typically have very large memory capacities. 
> Going to 64k 
> > will increase the memory footprint but I think we are 
> willling to make 
> > that sacrifice for the speed the larger page size brings us.
> > 
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> > 
> > Index: slub/arch/ia64/Kconfig
> > =================================> > --- slub.orig/arch/ia64/Kconfig	2007-05-31 
> 11:44:50.000000000 -0700
> > +++ slub/arch/ia64/Kconfig	2007-06-07 17:39:02.000000000 -0700
> > @@ -168,7 +168,7 @@ endchoice
> >  
> >  choice
> >  	prompt "Kernel page size"
> > -	default IA64_PAGE_SIZE_16KB
> > +	default IA64_PAGE_SIZE_64KB
> >  
> >  config IA64_PAGE_SIZE_4KB
> >  	bool "4KB"
> > Index: slub/arch/ia64/configs/sn2_defconfig
> > =================================> > --- slub.orig/arch/ia64/configs/sn2_defconfig	
> 2007-06-07 17:41:22.000000000 -0700
> > +++ slub/arch/ia64/configs/sn2_defconfig	2007-06-07 
> 17:56:34.000000000 -0700
> > @@ -110,8 +110,8 @@ CONFIG_IA64_SGI_SN2=y  CONFIG_MCKINLEY=y  # 
> > CONFIG_IA64_PAGE_SIZE_4KB is not set  # 
> CONFIG_IA64_PAGE_SIZE_8KB is 
> > not set -CONFIG_IA64_PAGE_SIZE_16KB=y -# 
> CONFIG_IA64_PAGE_SIZE_64KB is 
> > not set
> > +# CONFIG_IA64_PAGE_SIZE_16KB is not set 
> CONFIG_IA64_PAGE_SIZE_64KB=y
> >  # CONFIG_PGTABLE_3 is not set
> >  CONFIG_PGTABLE_4=y
> >  # CONFIG_HZ_100 is not set
> > Index: slub/arch/ia64/configs/gensparse_defconfig
> > =================================> > --- slub.orig/arch/ia64/configs/gensparse_defconfig	
> 2007-06-07 17:56:54.000000000 -0700
> > +++ slub/arch/ia64/configs/gensparse_defconfig	
> 2007-06-07 17:57:24.000000000 -0700
> > @@ -101,8 +101,8 @@ CONFIG_IA64_GENERIC=y  CONFIG_MCKINLEY=y  # 
> > CONFIG_IA64_PAGE_SIZE_4KB is not set  # 
> CONFIG_IA64_PAGE_SIZE_8KB is 
> > not set -CONFIG_IA64_PAGE_SIZE_16KB=y -# 
> CONFIG_IA64_PAGE_SIZE_64KB is 
> > not set
> > +# CONFIG_IA64_PAGE_SIZE_16KB is not set 
> CONFIG_IA64_PAGE_SIZE_64KB=y
> >  CONFIG_PGTABLE_3=y
> >  # CONFIG_PGTABLE_4 is not set
> >  # CONFIG_HZ_100 is not set
> > -
> > To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" 
> > in the body of a message to majordomo@vger.kernel.org More 
> majordomo 
> > info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Thanks
> 
> Jack Steiner (steiner@sgi.com)          651-683-5302
> Principal Engineer                      SGI - Silicon Graphics, Inc.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> 
