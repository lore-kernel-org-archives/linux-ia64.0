From: Linus Torvalds <torvalds@osdl.org>
Date: Fri, 14 Jan 2005 17:43:06 +0000
Subject: Re: page table lock patch V15 [0/7]: overview
Message-Id: <Pine.LNX.4.58.0501140924480.2310@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
 <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
 <20050113031807.GA97340@muc.de> <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
 <20050113180205.GA17600@muc.de> <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com>
 <20050114043944.GB41559@muc.de> <Pine.LNX.4.58.0501140838240.27382@schroedinger.engr.sgi.com>
 <20050114170140.GB4634@muc.de>
In-Reply-To: <20050114170140.GB4634@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org



On Fri, 14 Jan 2005, Andi Kleen wrote:
> 
> With all the other overhead (disabling exceptions, saving register etc.)
> will be likely slower. Also you would need fallback paths for CPUs 
> without MMX but with PAE (like Ppro). You can benchmark
> it if you want, but I wouldn't be very optimistic. 

We could just say that PAE requires MMX. Quite frankly, if you have a 
PPro, you probably don't need PAE anyway - I don't see a whole lot of 
people that spent huge amounts of money on memory and CPU (a PPro that had 
more than 4GB in it was _quite_ expensive at the time) who haven't 
upgraded to a PII by now..

IOW, the overlap of "really needs PAE" and "doesn't have MMX" is probably 
effectively zero.

That said, you're probably right in that it probably _is_ expensive enough
that it doesn't help. Even if the process doesn't use FP/MMX (so that you
can avoid the overhead of state save/restore), you need to

 - disable preemption
 - clear "TS" (pretty expensive in itself, since it touches CR0)
 - .. do any operations ..
 - set "TS" (again, CR0)
 - enable preemption

so it's likely a thousand cycles minimum on a P4 (I'm just assuming that
the P4 will serialize on CR0 accesses, which implies that it's damn
expensive), and possibly a hundred on other x86 implementations.

That's in the noise for something that does a full page table copy, but it
likely makes using MMX for single page table entries a total loss.

			Linus
