From: Dave Hansen <dave.hansen@intel.com>
Date: Thu, 24 Jan 2019 19:10:50 +0000
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Message-Id: <3a7a3cf2-b7d9-719e-85b0-352be49a6d0f@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190114082416.30939-1-mhocko@kernel.org>
 <20190124141727.GN4087@dhcp22.suse.cz>
In-Reply-To: <20190124141727.GN4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 1/24/19 6:17 AM, Michal Hocko wrote:
> and nr_cpus set to 4. The underlying reason is tha the device is bound
> to node 2 which doesn't have any memory and init_cpu_to_node only
> initializes memory-less nodes for possible cpus which nr_cpus restrics.
> This in turn means that proper zonelists are not allocated and the page
> allocator blows up.

This looks OK to me.

Could we add a few DEBUG_VM checks that *look* for these invalid
zonelists?  Or, would our existing list debugging have caught this?

Basically, is this bug also a sign that we need better debugging around
this?
