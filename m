From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 30 May 2005 00:18:22 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <429A5BCE.2040407@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bob,
> Another point to consider...
> 
> Both RH & SuSE release a single kernel binary image that is used on all
> platforms. IA64 discovers the platform type (Dig, SGI, HP, ...) during
> boot & sets up platform callouts to platform specific functions. We
> will need to select values for both CONFIG_SECTION_BITS &
> CONFIG_PHYSICAL_MEMORY_BITS that work on all IA64 platforms (or make these
> values configurable at runtime)
> 
After reading e-mails,
	physical address size -- 50bits
	section size	      -- 32bits
will be good as a default.
This can work on any ia64 platforms && Full-sized Hugetlb can be used without any tuning.

If people want to hot-remove smaller memory sections, he should adjust the params.

-- Kame

