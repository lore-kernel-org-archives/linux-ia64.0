From: Chris Wedgwood <cw@f00f.org>
Date: Mon, 27 Dec 2004 00:01:12 +0000
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free maps
Message-Id: <20041227000112.GB29854@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no> <E1ChwhG-00011c-00@be1.7eggert.dyndns.org> <87wtv464ty.fsf@deneb.enyo.de> <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Florian Weimer <fw@deneb.enyo.de>, 7eggert@gmx.de, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Dec 26, 2004 at 03:12:45PM -0800, Linus Torvalds wrote:

> Anyway, at this point I think the most interesting question is
> whether it actually improves any macro-benchmark behaviour, rather
> than just a page fault latency tester microbenchmark..

i can't see how is many cases it won't make things *worse* in many
cases, especially if you use hardware

it seems you will be evicting (potentially) useful cache-lines from
the CPU when using hardware scrubbing in many cases and when using the
CPU if the tuning isn't right just trashing the caches anyhow

I'd really like to see how it affects something like make -j<n> sorta
things (since gcc performance is something i personally care about
more than how well some contrived benchmark does)
