From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 21 May 2021 07:24:08 +0000
Subject: Re: [PATCH v1 1/1] kernel.h: split out panic and oops helpers (ia64 fix)
Message-Id: <41bbace7-1b09-8464-a082-e4152f07fdb4@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210520130557.55277-1-andriy.shevchenko@linux.intel.com>
 <f2420178-53d7-a1e4-eea7-5e1773835411@physik.fu-berlin.de>
 <YKZhcKqomWxH3eph@smile.fi.intel.com>
In-Reply-To: <YKZhcKqomWxH3eph@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kernel test robot <lkp@intel.com>

Hi Andy!

On 5/20/21 3:17 PM, Andy Shevchenko wrote:
> On Thu, May 20, 2021 at 03:12:24PM +0200, John Paul Adrian Glaubitz wrote:
>> On 5/20/21 3:05 PM, Andy Shevchenko wrote:
>>> Note, this patch is untested. I have no ia64 compiler at hand.
> 
>> I can test it later today.
> 
> Appreciate it, thanks!
> 
> This is against Linux Next (where Andrew's patches are sitting for a while).

I just pulled linux-next and was able to build a kernel for my RX-2600 without any
problems. Since your patch is already in the tree, I assume it's correct.

Do you want me to test anything else? I can test-boot the kernel later, but I want
to avoid that now since I don't want to turn on the noisy server while at home :-).

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
