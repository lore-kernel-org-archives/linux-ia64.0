From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 Aug 2008 18:56:07 +0000
Subject: RE: Pondering machvec ... was: [Patch] Remove sn2_defconfig.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309B82B72@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't think I understand your argument.  Are you essentially saying we
> should consider eliminating the mach_vec stuff entirely?  If so, will
> we essentially be saying that the distros need to build a seperate kernel
> for each of tiger, zx1, sn2, and uv?

No ... exactly the opposite ... I'm wondering whether we should give
up maintaining/building all the tiger_, zx1_ configs and only have the
generic one ... since it appears that the number of end users of non-generic
kernels can be counted on the toes of one foot.

-Tony
