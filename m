From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Dec 2009 17:48:19 +0000
Subject: RE: [PATCH] mm/vmalloc: don't use vmalloc_end
Message-Id: <4BDB13256095B24D9644F65379E6042656CFE088@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>
 <20091207153552.0fadf335.akpm@linux-foundation.org>
 <4B1E1B1B0200007800024345@vpn.id2.novell.com>
 <alpine.DEB.2.00.0912091128280.16491@router.home>
In-Reply-To: <alpine.DEB.2.00.0912091128280.16491@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Tony: Can you confirm that the new percpu stuff works on IA64.

If all the pieces are in (either Linus tree, or linux-next) then
it is working (well these both still build & boot on my test systems).

-Tony
