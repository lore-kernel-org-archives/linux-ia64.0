From: "Jan Beulich" <JBeulich@novell.com>
Date: Tue, 08 Dec 2009 08:23:39 +0000
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <4B1E1B1B0200007800024345@vpn.id2.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
 <20091207153552.0fadf335.akpm@linux-foundation.org>
In-Reply-To: <20091207153552.0fadf335.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tony.luck@intel.com, tj@kernel.org, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>> Andrew Morton <akpm@linux-foundation.org> 08.12.09 00:35 >>>
>(cc linux-ia64)
>
>On Mon, 07 Dec 2009 16:24:03 +0000
>"Jan Beulich" <JBeulich@novell.com> wrote:
>
>> At least on ia64 vmalloc_end is a global variable that VMALLOC_END
>> expands to. Hence having a local variable named vmalloc_end and
>> initialized from VMALLOC_END won't work on such platforms. Rename
>> these variables, and for consistency also rename vmalloc_start.
>> 
>
>erk.  So does 2.6.32's vmalloc() actually work correctly on ia64?

According to Tejun the problem is just cosmetic (i.e. causes build
warnings), since the functions affected aren't being used (yet) on
ia64. So feel free to drop the patch again, given that he has a patch
queued to address the issue by renaming the arch variable.

I wonder though why that code is being built on ia64 at all if it's not
being used (i.e. why it doesn't depend on a CONFIG_*, HAVE_*, or
NEED_* manifest constant).

Jan

