From: Grant Grundler <iod00d@hp.com>
Date: Tue, 15 Feb 2005 17:35:46 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <20050215173546.GB15050@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 15, 2005 at 03:43:10AM -0500, Jes Sorensen wrote:
> None of the ones I know well have this problem, but I have little
> knowledge about this level of stuff on most architectures. The ones
> that could have issues would probably be like PPC, PARISC and maybe
> Alpha .....

With parisc 2.0 CPU, one could map the same physical address
as both cacheable and uncacheable via two entries in the page table.
AFAIK, the uncacheable bit is only use to map MMIO address space.
In practice, I'm not sure what happens since I'm not aware of
any need for both mappings at the same time because we can use
"LDWA" (Load Word Absolute). LDWA can load from (almost) any physical
address and is by nature uncached (caches are VIVT).

Older PA1.x CPU had hardwired 0xf0000000-0xffffffff to be uncacheable.
I.e. it's not possible to have an overlap.

hth,
grant
