From: Linus Torvalds <torvalds@osdl.org>
Date: Sun, 26 Dec 2004 23:12:45 +0000
Subject: Re: Prezeroing V2 [3/4]: Add support for ZEROED and NOT_ZEROED free
Message-Id: <Pine.LNX.4.58.0412261511030.2353@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <fa.n0l29ap.1nqg39@ifi.uio.no> <fa.n04s9ar.17sg3f@ifi.uio.no>
 <E1ChwhG-00011c-00@be1.7eggert.dyndns.org> <87wtv464ty.fsf@deneb.enyo.de>
In-Reply-To: <87wtv464ty.fsf@deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Weimer <fw@deneb.enyo.de>
Cc: 7eggert@gmx.de, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Mon, 27 Dec 2004, Florian Weimer wrote:
> 
> But overwritting with zeros is commonly called "scrubbing", as in
> "password scrubbing".

On the other hand, "memory scrubbing" in an OS sense is most often used
for reading and re-writing the same thing to fix correctable ECC failures.

Anyway, at this point I think the most interesting question is whether it 
actually improves any macro-benchmark behaviour, rather than just a page 
fault latency tester microbenchmark..

		Linus
