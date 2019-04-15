From: Dave Hansen <dave.hansen@intel.com>
Date: Mon, 15 Apr 2019 15:43:18 +0000
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
Message-Id: <77b364e5-a30c-964a-6985-00b759dac128@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190226131201.GA10588@dhcp22.suse.cz>
 <20190415114209.GJ3366@dhcp22.suse.cz>
In-Reply-To: <20190415114209.GJ3366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>

On 4/15/19 4:42 AM, Michal Hocko wrote:
>> Friendly ping. I haven't heard any complains so can we route this via
>> tip/x86/mm or should we go via mmotm.
> It seems that Dave is busy. Let's add Andrew. Can we get this [1] merged
> finally, please?

Sorry these slipped through the cracks.

These look sane to me.  Because it pokes around mm/page_alloc.c a bit,
and could impact other architectures, my preference would be for Andrew
to pick these up for -mm.  But, I don't feel that strongly about it.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>
