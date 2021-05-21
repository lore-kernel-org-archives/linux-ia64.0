From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri, 21 May 2021 12:02:11 +0000
Subject: Re: [PATCH v1 1/1] kernel.h: split out panic and oops helpers (ia64 fix)
Message-Id: <YKehQyAn7rgXL9Bb@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210520130557.55277-1-andriy.shevchenko@linux.intel.com>
 <f2420178-53d7-a1e4-eea7-5e1773835411@physik.fu-berlin.de>
 <YKZhcKqomWxH3eph@smile.fi.intel.com>
 <41bbace7-1b09-8464-a082-e4152f07fdb4@physik.fu-berlin.de>
In-Reply-To: <41bbace7-1b09-8464-a082-e4152f07fdb4@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kernel test robot <lkp@intel.com>

On Fri, May 21, 2021 at 09:24:08AM +0200, John Paul Adrian Glaubitz wrote:
> On 5/20/21 3:17 PM, Andy Shevchenko wrote:
> > On Thu, May 20, 2021 at 03:12:24PM +0200, John Paul Adrian Glaubitz wrote:
> >> On 5/20/21 3:05 PM, Andy Shevchenko wrote:
> >>> Note, this patch is untested. I have no ia64 compiler at hand.
> > 
> >> I can test it later today.
> > 
> > Appreciate it, thanks!
> > 
> > This is against Linux Next (where Andrew's patches are sitting for a while).
> 
> I just pulled linux-next and was able to build a kernel for my RX-2600 without any
> problems. Since your patch is already in the tree, I assume it's correct.
> 
> Do you want me to test anything else? I can test-boot the kernel later, but I want
> to avoid that now since I don't want to turn on the noisy server while at home :-)

Nothing is required anymore, thanks for your help with testing!

-- 
With Best Regards,
Andy Shevchenko

