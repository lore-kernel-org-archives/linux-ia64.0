From: Dean Nelson <dcn@sgi.com>
Date: Tue, 25 Mar 2008 20:14:23 +0000
Subject: Re: [Patch 0/5] prepare XPC and XPNET to support SGI UV
Message-Id: <20080325201423.GB4446@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080325192524.343385569@attica.americas.sgi.com>
In-Reply-To: <20080325192524.343385569@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Mar 25, 2008 at 02:25:24PM -0500, dcn@sgi.com wrote:
> This set of five patches moves XPC and XPNET to drivers/misc/xp in preparation
> for enabling X86_64 support.

It looks like the 2nd patch of this set has been blocked from the mailing
list because of its size. At least that's my assumption. The size of the
five patches are as follows (listed in patch order):

 -rw-r--r-- 1 dcn os1   4880 2008-03-25 14:05 uncached-pages
 -rw-r--r-- 1 dcn os1 471050 2008-03-25 14:10 move-xp
 -rw-r--r-- 1 dcn os1 203046 2008-03-25 14:14 generic-xp
 -rw-r--r-- 1 dcn os1 163868 2008-03-25 14:17 Lindent
 -rw-r--r-- 1 dcn os1  49723 2008-03-25 14:46 checkpatch.pl

The missing patch moved XPC and XPNET from arch/ia64/sn to drivers/misc/xp.
How should such a patch be submitted?

Thanks,
Dean
