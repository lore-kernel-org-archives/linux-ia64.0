From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 12 Jul 2005 19:29:25 +0000
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low()
Message-Id: <1121196565.5992.2.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050712152715.44CD.Y-GOTO@jp.fujitsu.com>
	 <20050712183021.GC3987@w-mikek2.ibm.com>
In-Reply-To: <20050712183021.GC3987@w-mikek2.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "Luck, Tony" <tony.luck@intel.com>, ia64 list <linux-ia64@vger.kernel.org>, "Martin J. Bligh" <mbligh@mbligh.org>

On Tue, 2005-07-12 at 11:30 -0700, Mike Kravetz wrote:
> FYI - While hacking on the memory hotplug code, I added a special
> '#define MAX_DMA_PHYSADDR' to get around this issue on such architectures.
> Most likely, this isn't elegant enough as a real solution.  But it does
> point out that __pa(MAX_DMA_ADDRESS) doesn't always give you what you
> expect.

Didn't we create a MAX_DMA_PHYSADDR or something, so that people could
do this if they want?

-- Dave

