From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 03 Jan 2005 20:30:29 +0000
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free
Message-Id: <Pine.LNX.4.58.0501031225130.22688@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no>
 <E1ChwhG-00011c-00@be1.7eggert.dyndns.org> <87wtv464ty.fsf@deneb.enyo.de>
 <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Florian Weimer <fw@deneb.enyo.de>, 7eggert@gmx.de, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 26 Dec 2004, Linus Torvalds wrote:

> Anyway, at this point I think the most interesting question is whether it
> actually improves any macro-benchmark behaviour, rather than just a page
> fault latency tester microbenchmark..

Any suggestion as to what macro-benchmark would allow that kind of
testing? I tried lmbench but it immediately writes to the complete page
that was allocated. I tried to vary the number of cache cells touched
after an allocation of an prezeroed page. Unsurprisingly it degenerates to
regular behavior if all cache lines are touched. So we would need a
benchmar that allows sparse memory use testing and preferably is able to
also allow SMP tests. I will test with some of the typical apps running
on  Altix machines but those are extremely heavy in terms of memory use
and  will likely be as positive as my microbenches.

BTW my bench does simulate the typical behavior of such an app using a
sparse array and allows the configuration of the number of cache lines
per page to touch.

