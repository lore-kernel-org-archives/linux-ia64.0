From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 21 Jan 2006 21:11:38 +0000
Subject: RE: ia64: allnoconfig build fails
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F057DC961@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601210320.05771.len.brown@intel.com>
In-Reply-To: <200601210320.05771.len.brown@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Need to wrap huge_zonelist function with CONFIG_HUGETLBFS.
>
>
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

Fixes this new problem ... allnoconfig still fails for me
with lots of:

     undefined reference to `vmem_map'

and a few

     undefined reference to `ia64_pfn_valid'

but these have been around for a while.

-Tony
