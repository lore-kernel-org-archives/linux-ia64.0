From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Jan 2005 21:59:53 +0000
Subject: RE: fixing 2.6.10 UP builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02A677A8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>> 2.6.10 built as UP for me (I have it running on zx2000).
>
>A zx1 specific kernel?  Most of these changes are NUMA and 
>discontig specific, 
>so they apply more to generic kernels than particular types.

Ah yes ... I based my config on the zx1_config file ... a generic
UP build does have problems that need to be fixed.

-Tony
