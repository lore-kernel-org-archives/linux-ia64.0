From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 09 Dec 2009 18:46:24 +0000
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <alpine.DEB.2.00.0912091241370.16491@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com> <alpine.DEB.2.00.0912091128280.16491@router.home> <4B1FE81F.30408@sgi.com> <alpine.DEB.2.00.0912091218060.16491@router.home>
 <4B1FEE5C.1030303@sgi.com>
In-Reply-To: <4B1FEE5C.1030303@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Travis <travis@sgi.com>
Cc: tony.luck@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 9 Dec 2009, Mike Travis wrote:

> > Boot with 2.6.32 and see if the per cpu allocator works. Check if there
> > are any changes to memory consumption. Create a few thousand virtual
> > ethernet devices and see if the system keels over.
>
> Any advice on how to go about the above would be helpful... ;-)

I believe you can create an additional alias device with

ifconfig eth0:<N>

or so.

> I'm doing some aim7/9 comparisons right now between SPARSE and DISCONTIG
> memory configs using sles11 + 2.6.32.  Which other benchmarks would you
> recommend for the other tests?

See f.e. http://kernel-perf.sourceforge.net/about_tests.php

lmbench?

