From: Tejun Heo <tj@kernel.org>
Date: Tue, 08 Dec 2009 08:29:10 +0000
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <4B1E0E56.8020003@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com>
In-Reply-To: <4B1E1B1B0200007800024345@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@novell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tony.luck@intel.com, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On 12/08/2009 05:23 PM, Jan Beulich wrote:
> According to Tejun the problem is just cosmetic (i.e. causes build
> warnings), since the functions affected aren't being used (yet) on
> ia64. So feel free to drop the patch again, given that he has a patch
> queued to address the issue by renaming the arch variable.
> 
> I wonder though why that code is being built on ia64 at all if it's not
> being used (i.e. why it doesn't depend on a CONFIG_*, HAVE_*, or
> NEED_* manifest constant).

Hmm... it shouldn't be building.  Can you please attach .config?

Thanks.

-- 
tejun
