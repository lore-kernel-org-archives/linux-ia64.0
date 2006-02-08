From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Feb 2006 22:35:37 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05A6E3E7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Jes Sorensen <jes@sgi.com>

Drifting a little (perhaps).  "make allnoconfig" produces
a config that doesn't compile. Lots or warnings during compile
about implicit declaration of ia64_pfn_valid.  Then link errors
for vmem_map and ia64_pfn_valid.

What's the right thing to do about this?  It's been broken for a
long time (definitely since SPARSE support was added, perhaps longer).


-Tony
