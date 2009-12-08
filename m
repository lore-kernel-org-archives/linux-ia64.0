From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 08 Dec 2009 00:50:29 +0000
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <20091208005028.GF9482@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org>
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, tj@kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

On Mon, Dec 07, 2009 at 03:35:52PM -0800, Andrew Morton wrote:
> erk.  So does 2.6.32's vmalloc() actually work correctly on ia64?
> 
> Perhaps vmalloc_end wasn't a well chosen name for an arch-specific
> global variable.

Can we enable -Wshadow now?  Please?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
