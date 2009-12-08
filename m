From: Tejun Heo <tj@kernel.org>
Date: Tue, 08 Dec 2009 00:40:10 +0000
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <4B1DA06A.1050004@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org>
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

Hello,

On 12/08/2009 08:35 AM, Andrew Morton wrote:
> arch/m68k/include/asm/pgtable_mm.h does the same thing.  Did it break too?

Oh... m64k does the same thing.  I think the correct thing to do here
would be to convert arch code as in ia64.  I think defining
VMALLOC_END to vmalloc_end is a bit error-prone.  If it were defined
simply as vmalloc_end, it's unnoticeable by both the compiler and
developer.

Thanks.

-- 
tejun
