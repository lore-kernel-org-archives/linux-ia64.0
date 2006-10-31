From: Horms <horms@verge.net.au>
Date: Tue, 31 Oct 2006 03:29:17 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061031032917.GA15310@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 30, 2006 at 11:49:00AM +0000, Mel Gorman wrote:
> On Mon, 30 Oct 2006, Horms wrote:
> 
> >On Mon, Oct 30, 2006 at 06:11:26PM +0900, Horms wrote:
> >>On Fri, Oct 27, 2006 at 10:15:16AM +0100, Andy Whitcroft wrote:
> >>
> >>>A logical next step might be to bodge things such that we offer up the
> >>>kernel image as an active range and see if that sorts out the alignment
> >>>issue we are seeing, this will allow us to be certain it is the kernel
> >>>image in this area.  Something like the following inserted into
> >>>register_memory() might work:
> >>>
> >>>	add_active_range(0, code_resource.start >> PAGE_SHIFT,
> >>>			    data_resource.end >> PAGE_SHIFT);
> >>>
> >>>Not sure this is the right thing as a fix, but would help confirm the
> >>>theory.
> >>
> >>I will poke around with that. Though it will probably be tomorrow.
> >
> >Hi,
> >
> >I did try adding that line to the end of register_memory(),
> >however it didn't seem to alter the behaviour that I am seeing.
> >The log is below, including the EFI map, in case it is useful.
> >
> 
> Judging from the output of early_node_map[], the range of memory the kdump 
> kernel is in is still not being registered so the memmap is not initialised. In 
> the EFI output, we see
> 
> mem12: type=2, attr=0xb, range=[0x0000000010000000-0x00000000104b0000) (4MB)
> mem13: type=2, attr=0xb, range=[0x00000000104b0000-0x00000000104c0000) (0MB)
> mem14: type=2, attr=0xb, range=[0x00000000104c0000-0x0000000010760000) (2MB)
> mem15: type=7, attr=0xb, range=[0x0000000010760000-0x000000001ffe4000) (248MB)
> 
> The first three ranges is where I suspect the kernel is and with "type=2", 
> add_active_range() is not being called when walking the EFI map.

I will try and verify this for you.

> If this memory 
> is marked correctly, it will get registered correctly.
> 
> Try calling add_active_range(0, 16384, 16855) manually after the call to 
> efi_memmap_walk(register_active_ranges, &nid) and see does the kernel boot.

I'll try that and get back to you.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

