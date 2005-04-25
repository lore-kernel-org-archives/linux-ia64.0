From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 25 Apr 2005 14:41:35 +0000
Subject: efi_memmap_walk_uc, was Re: [patch] mspec driver for 2.6.12-rc2-mm3
Message-Id: <20050425144135.GB9902@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16987.39773.267117.925489@jaguar.mkp.net> <20050412032747.51c0c514.akpm@osdl.org> <yq07jj8123j.fsf@jaguar.mkp.net> <20050413204335.GA17012@infradead.org> <yq08y3bys4e.fsf@jaguar.mkp.net> <20050424101615.GA22393@infradead.org> <yq03btftb9u.fsf@jaguar.mkp.net>
In-Reply-To: <yq03btftb9u.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Apr 25, 2005 at 06:13:01AM -0400, Jes Sorensen wrote:
> Your approach doesn't work. This relies on first-touch to get
> performance, remap_pfn_range_node wouldn't work.
> 
> Christoph> I'm pretty sure this was NACKed on the ia64 list, and SGI
> Christoph> was told to do a more generic efi memmap walk.
> >>  No the issue back then was that the driver just took the memory
> >> and kept it to itself. The new approach exports it for other users.
> 
> Christoph> That comment doesn't make sense at all to me.  exports what
> Christoph> to what other users.  And through what way.  Please bring
> Christoph> this issue up on the ia64 list again.  (also please post
> Christoph> this patch to linux-ia64, too)
> 
> mspec_alloc_page can be called from anywhere by anyone who wants to
> allocate an uncached page. The old fetchop driver just took the
> uncached memory and kept to itself. Thats what I am talking about!
> Earlier versions of the patch has already been by the ia64 list, we're
> down to details here.

See the thread starting at
http://marc.theaimsgroup.com/?l=linux-ia64&m5883467032028&w=2

My reading is that it requests two things:

 - not duplicating the EFI memmap walk in a new function but rather
   have generic EFI memmap walk replaces the current efi_memmap_walk
 - an uncached memory allocator below the driver (not in the driver!).
   Your allocator design also doesn't seem to take many of the suggestions
   and recommendations in that thread in account.
