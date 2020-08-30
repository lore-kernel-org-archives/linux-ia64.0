From: Mike Rapoport <rppt@linux.ibm.com>
Date: Sun, 30 Aug 2020 09:56:48 +0000
Subject: Re: [ALTERNATE PATCH] memblock: fix min_low_pfn/max_low_pfn build errors
Message-Id: <20200830095648.GA424181@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829000139.2513-1-rdunlap@infradead.org>
 <20200829130429.GG167163@linux.ibm.com>
 <a0665bb7-3389-1178-0a79-2155fb88255d@infradead.org>
In-Reply-To: <a0665bb7-3389-1178-0a79-2155fb88255d@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Simek <monstr@monstr.eu>, Michal Simek <michal.simek@xilinx.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Hi Randy,

On Sat, Aug 29, 2020 at 08:40:51AM -0700, Randy Dunlap wrote:
> On 8/29/20 6:04 AM, Mike Rapoport wrote:
> > On Fri, Aug 28, 2020 at 05:01:39PM -0700, Randy Dunlap wrote:
> >> Export min_low_pfn & max_low_pfn in mm/memblock.c to fix build errors
> >> on arch/microblaze/ and arch/ia64/: (e.g.)
> > 
> > Please don't. This would give driver developers a wrong impression that
> > these variables can be used to query memory boundaries, but this is not
> > the case, at least not on all architectures.
> > 
> > I would prefer fixing it up locally for microblaze and ia64.
> 
> I did that.
> and that's why this is labeled as an ALTERNATE PATCH.

I've seen that, I just wanted to make sure that Andrew wouldn't pick
this one :)

I can help with taking microblaze and ia64 patches via memblock tree
once we have Acks from the arch maintainers.
 
> thanks.
> -- 
> ~Randy
> 

-- 
Sincerely yours,
Mike.
