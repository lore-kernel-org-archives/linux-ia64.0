From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Feb 2006 19:48:43 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05A6E0C5@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207231713.GG3524@stusta.de>
In-Reply-To: <20060207231713.GG3524@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>, Alex Williamson <alex.williamson@hp.com>
Cc: Adrian Bunk <bunk@stusta.de>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> That could explain it, but the question is whether one would want to
> boot a generic kernel when running on a simulator. After all then every
> cycle does count ;)

You might if you wanted to use the simulator to debug a problem that
only showed up in a generic kernel.

-Tony
