From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 12 Oct 2006 21:40:25 +0000
Subject: RE: [PATCH 4/4] vmm: Use a static memory map
Message-Id: <000001c6ee47$0764e7e0$db34030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061012191828.21498.95831.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, October 12, 2006 12:18 PM
> IA64 currently uses a dynamically configured memory map that is taken off
> the end of VMALLOC space. This means that we do some tweaking with some
> core constants that now refer to variables and we keep having to
> get the address of the virtual memory map and the limits from memory.
> This patch makes pfn_to_page and page_to_pfn possible without referencing
> any memory location.
> 
> So, the size of the virtual memory map is always less than 8 Terabyte.
> 
> I think its reasonable to take these 8 Terabyte away from the 128 Terabyte
> that we currently reserve for support for VMALLOC space.
> 
> Advantages:
> - virt_to_page, page_address, pfn_to_page, page_to_pfn become simple address
>   calculations without a memory reference.

I like the concept a lot.


> - This patch will enable later patches to move the virtual memory map into
>   another region with a larger page size. Larger page sizes will reduce
>   TLB pressure.

I like that even more, which region are you going to move it to?
