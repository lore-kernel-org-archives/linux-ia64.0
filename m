From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 24 Feb 2006 20:25:13 +0000
Subject: RE: Export cpu cache info by sysfs
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05CB0C13@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140066744.13438.27.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks much better.  Still a couple of questions:

> Below new patch exports 8 attributes:
> 1) level

The software developers manual calls the cache levels 1, 2, 3
but we report them as 0, 1, 2 (which is compatible with x86 versions
of these /sys files).  Is it better to match the docs, or other
architecture?

2) type
For a combined cache x86 uses the string "Unified", you use
"Data/Instruction" ... again which is better?

-Tony
