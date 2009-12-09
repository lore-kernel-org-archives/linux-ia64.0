From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 09 Dec 2009 17:31:20 +0000
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <alpine.DEB.2.00.0912091128280.16491@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com>
In-Reply-To: <4B1E1B1B0200007800024345@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 8 Dec 2009, Jan Beulich wrote:

> According to Tejun the problem is just cosmetic (i.e. causes build
> warnings), since the functions affected aren't being used (yet) on
> ia64. So feel free to drop the patch again, given that he has a patch
> queued to address the issue by renaming the arch variable.

I thought the new code must be used in order for the new percpu allocator
to work? Or is this referring to other code?

> I wonder though why that code is being built on ia64 at all if it's not
> being used (i.e. why it doesn't depend on a CONFIG_*, HAVE_*, or
> NEED_* manifest constant).

Tony: Can you confirm that the new percpu stuff works on IA64? (Or is
there nobody left to care?)
