From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 13 Oct 2006 00:29:35 +0000
Subject: Re: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <Pine.LNX.4.64.0610121727560.22717@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 12 Oct 2006, Luck, Tony wrote:

> > So, the size of the virtual memory map is always less than 8 Terabyte.
> 
> 32 TB for 4K pagesize using current physical address space limit and
> existing Linux sizeof(struct page)

Ok. Well in that unlikely case we can probably sacrifice more?

> > I think its reasonable to take these 8 Terabyte away from the 128 Terabyte
> > that we currently reserve for support for VMALLOC space.
> 
> Does it still sound as good to take 32/128 TB?  What if the physical
> address space gets another 4 bits ... even with a 16K pagesize you'd
> need the whole 128TB.

The limits discussed here are for 3 level page tables. All of this gets 
much bigger with 4 level page tables.
