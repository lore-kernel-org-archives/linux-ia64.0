From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 08 Feb 2006 19:21:19 +0000
Subject: RE: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <1139426479.26420.189.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05A6DEE7@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05A6DEE7@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Jes Sorensen <jes@sgi.com>, Adrian Bunk <bunk@stusta.de>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 2006-02-08 at 10:35 -0800, Luck, Tony wrote:

> The current set looks close ... perhaps PCI should be added as it isn't
> likely to inconvenience anyone, but SMP is a lot further into murky territory

   Seems like maybe PCI was removed so that it was possible to configure
a generic kernel to boot on the simulator...  I could imagine not having
PCI might have some degree of usefulness when using a ramdisk.  Isn't
this what the defconfigs are for?

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

