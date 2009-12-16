From: Greg KH <greg@kroah.com>
Date: Wed, 16 Dec 2009 23:12:10 +0000
Subject: Re: [stable] [PATCH -stable] vmalloc: conditionalize build of
Message-Id: <20091216231210.GB9421@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
 <20091207153552.0fadf335.akpm@linux-foundation.org>
 <4B1E1B1B0200007800024345@vpn.id2.novell.com>
 <4B1E0E56.8020003@kernel.org>
 <4B1E1EE60200007800024364@vpn.id2.novell.com>
 <4B1E1513.3020000@kernel.org>
 <4B203614.1010907@novell.com>
In-Reply-To: <4B203614.1010907@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tejun Heo <teheo@novell.com>
Cc: stable@kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Beulich <JBeulich@novell.com>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 10, 2009 at 08:43:16AM +0900, Tejun Heo wrote:
> pcpu_get_vm_areas() is used only when dynamic percpu allocator is used
> by the architecture.  In 2.6.32, ia64 doesn't use dynamic percpu
> allocator and has a macro which makes pcpu_get_vm_areas() buggy via
> local/global variable aliasing and triggers compile warning.
> 
> The problem is fixed in upstream and ia64 uses dynamic percpu
> allocators, so the only left issue is inclusion of unnecessary code
> and compile warning on ia64 on 2.6.32.
> 
> Don't build pcpu_get_vm_areas() if legacy percpu allocator is in use.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jan Beulich <JBeulich@novell.com>
> Cc: stable@kernel.org
> ---
> Please note that this commit won't appear on upstream.

So this is only needed for the .32 kernel stable tree?  Not .31?  And
it's not upstream as it was solved differently there?

thanks,

greg k-h
