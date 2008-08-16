From: Jes Sorensen <jes@sgi.com>
Date: Sat, 16 Aug 2008 10:08:21 +0000
Subject: Re: Pondering machvec ... was: [Patch] Remove sn2_defconfig.
Message-Id: <48A6A715.2070103@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA309B82A07@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>> I don't think I understand your argument.  Are you essentially saying we
>> should consider eliminating the mach_vec stuff entirely?  If so, will
>> we essentially be saying that the distros need to build a seperate kernel
>> for each of tiger, zx1, sn2, and uv?
> 
> No ... exactly the opposite ... I'm wondering whether we should give
> up maintaining/building all the tiger_, zx1_ configs and only have the
> generic one ... since it appears that the number of end users of non-generic
> kernels can be counted on the toes of one foot.

Hi Tony,

IMHO it would be fine to just run the generic builds and forget about
the specialized ones. We can probably simplify the machvec
infrastructure a bit by doing so, but I don't see how we're going to get
rid of the bulk of it..... says the guy who is in the process of adding
more entries :-)

Cheers,
Jes

