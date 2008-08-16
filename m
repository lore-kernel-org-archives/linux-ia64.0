From: Robin Holt <holt@sgi.com>
Date: Sat, 16 Aug 2008 00:19:33 +0000
Subject: Re: Pondering machvec ... was: [Patch] Remove sn2_defconfig.
Message-Id: <20080816001933.GQ6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 15, 2008 at 11:56:07AM -0700, Luck, Tony wrote:
> > I don't think I understand your argument.  Are you essentially saying we
> > should consider eliminating the mach_vec stuff entirely?  If so, will
> > we essentially be saying that the distros need to build a seperate kernel
> > for each of tiger, zx1, sn2, and uv?
> 
> No ... exactly the opposite ... I'm wondering whether we should give
> up maintaining/building all the tiger_, zx1_ configs and only have the
> generic one ... since it appears that the number of end users of non-generic
> kernels can be counted on the toes of one foot.

I won't speak to the others, but as for sn2_defconfig SGI appears to
still be a go.  I did get feedback from a couple engineers that had been
using the sn2_defconfig, but both seem to accept the generic_defconfig
as an adequate substitue now that it has our needed disk drivers.


Thanks,
Robin
