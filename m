From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Feb 2005 18:04:49 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <16914.14785.714505.410952@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 15 Feb 2005 03:43:10 -0500, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

  Tony> Is ia64 the only architecture that has uncached vs. cached
  Tony> access issues?  If so, the PG_arch_1 might have to be the
  Tony> solution, but surely others have cache coherence problems too
  Tony> if there are mixed cacheable and uncacheable access to the
  Tony> same memory?  In which case a new generic bit would be more
  Tony> appropriate.

  Jes> None of the ones I know well have this problem, but I have
  Jes> little knowledge about this level of stuff on most
  Jes> architectures. The ones that could have issues would probably
  Jes> be like PPC, PARISC and maybe Alpha .....

Well, any CPU that allows overlapping mappings and does _any_ sort of
speculative accesses will have a problem.  The only question is
whether you'll get an explicit error notification (e.g., MCA) or
silent data corruption.

	--david
