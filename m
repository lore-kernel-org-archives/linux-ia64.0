From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 15 Feb 2005 08:43:10 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0fyzyp61t.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> Anyway, it seems that lcrash at least only accesses the memory
>> using read() and write()? which means it is relatively easy to
>> using a struct page flag to do uncached vs cached access on the
>> fly. mmap on the other hand would be a bit of a nightmare as it
>> would require a custom fault handler that would know when to go
>> cached and when not to.
>> 
>> How would you feel about using PG_arch_1 for this on ia64?

Tony> Is ia64 the only architecture that has uncached vs. cached
Tony> access issues?  If so, the PG_arch_1 might have to be the
Tony> solution, but surely others have cache coherence problems too if
Tony> there are mixed cacheable and uncacheable access to the same
Tony> memory?  In which case a new generic bit would be more
Tony> appropriate.

None of the ones I know well have this problem, but I have little
knowledge about this level of stuff on most architectures. The ones
that could have issues would probably be like PPC, PARISC and maybe
Alpha .....

Tony> A few weeks back there was also some discussion about allocating
Tony> one or more bits to mark bad pages (those containing ECC errors)
Tony> as "do not touch".

Probably something which needs to be done sooner or later.

Cheers,
Jes
