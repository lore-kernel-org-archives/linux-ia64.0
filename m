From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Jan 2005 21:54:51 +0000
Subject: RE: pgprot_writecombine & shub 1.x
Message-Id: <16869.40107.667336.912445@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Jan 2005 20:31:30 +0100 (CET), Hugo Kohmann <hugo@dolphinics.no> said:

  Hugo> Is there any new plans to implement support for writecombine
  Hugo> in kernel space ?

I don't know of anybody who's working on it at the moment.

  Hugo> We have implemented a new socket transport family, AF_SCI,
  Hugo> that provides UDP/TCP compliant transport over SCI that needs
  Hugo> writecombine to archieve max througpht and low latency for
  Hugo> small messages. Large messages can be send using DMA, but
  Hugo> small messages highly benefit from memory mapped
  Hugo> transmission....

I think there are two somewhat separate issues here:

 (1) WC mapping of uncachable address-ranges.
 (2) WC mapping of memory.

(1) isn't much of an issue (at least for today's chips; I think we may
still be violating the architecture if we end up mapping the same
address-range both UC and WC, but current chips don't care, AFAIK).

(2) is where things get trickier.  You'd have to make sure that any
memory that's mapped WC is allocated in granule-sized chunks.  There
is no support for this at the moment.  I do think it might be
worthwhile to support this, but don't know of anybody working on it.

	--david
