From: Horms <horms@verge.net.au>
Date: Mon, 06 Nov 2006 03:26:56 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061106032654.GA7501@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 06, 2006 at 12:18:00PM +0900, Horms wrote:
> On Fri, Nov 03, 2006 at 06:06:45PM +0800, Zou Nan hai wrote:
> > On Fri, 2006-11-03 at 17:27, Mel Gorman wrote:
> > > On Fri, 3 Nov 2006, Zou, Nanhai wrote:
> > > 
> > > > Hi,
> > > > 	This patch should fix the issue.
> > > >
> > > 
> > > It would appear to fix the issue for IA64 but you are blotting over the 
> > > issue that the map is reporting a one page hole. On arches with really 
> > > adjacent regions that are getting merged, the regions will appear to 
> > > overlap by one page. What can happen is something like this
> > > 
> > > PFN ranges for nodes
> > > Node 1: 0 -> 1000
> > > Node 0: 1000 -> 2000
> > > 
> > Hi,
> >  But the patch Andy and you are commenting is not my patch...., It was
> > in the previous thread. 
> > My patch was in the attachment.....
> > 
> >  Sorry for using outlook to send that patch as attachment, my Linux box
> > was not accessable at the time when I was posting the patch.
> >  I post the patch again, and copy the discription from my previous mail.
> > 
> > When ia64 kernel is configured as discontinuous memory model, 
> > active_pages are added through efi_memmap_walk(filter_rsvd_memory, count_node_pages). 
> > filter_rsvd_memory  will filter out all regions in rsvd_regions include 
> > - boot param
> > - mem map
> > - initrd
> > - command line
> > - **** kernel code and data ***
> > - kernel map built from efi memmap
> > - crash kernel reserved region
> > So the kernel code and data is excluded even without kdump support,
> > check /proc/iomem and dmesg for early_node_data can verify that.
> > But magically, the first kernel boots happily without any complain...,
> > I guess that is related to the init value in memmap. 
> > 
> > This patch use another filter to add_acvitive_pages, only exclude crash kernel reserved region if CONFIG_KEXEC is on.
> 
> Hi Nan hai,
> 
> I can confirm that your patch does indeed resolve the problem that I am
> seeint, and it seems to produce PFN ranges that are correct. Though I
> must admit I don't entirely follow how skipping the crash-kernel range
> in the first kernel effects things in the second kernel.
> 
> Also, I am wondering if the following patch, which just 
> has filter_rsvd_memory() skip the region matching crashk_res
> achives the same as your patch. It does seem to work.

Sorry, I was mistaken. My patch (below) does not work.

> Index: linux-2.6/arch/ia64/kernel/setup.c
> =================================> --- linux-2.6.orig/arch/ia64/kernel/setup.c	2006-11-06 11:30:56.000000000 +0900
> +++ linux-2.6/arch/ia64/kernel/setup.c	2006-11-06 12:07:08.000000000 +0900
> @@ -163,6 +163,9 @@
>  	func = arg;
>  
>  	for (i = 0; i < num_rsvd_regions; ++i) {
> +		if (rsvd_region[i].start = crashk_res.start &&
> +		    rsvd_region[i].end = crashk_res.end)
> +			continue;
>  		range_start = max(start, prev_start);
>  		range_end   = min(end, rsvd_region[i].start);
>  

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

