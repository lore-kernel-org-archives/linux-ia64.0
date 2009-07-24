From: Frans Pop <elendil@planet.nl>
Date: Fri, 24 Jul 2009 23:25:04 +0000
Subject: Re: [PATCH] ia64: minor Makefile simplification through use of cc-ifversion
Message-Id: <200907250125.06102.elendil@planet.nl>
List-Id: <linux-ia64.vger.kernel.org>
References: <200907232056.51064.elendil@planet.nl> <200907242023.12478.elendil@planet.nl> <20090724231511.GA20607@linux-os.sc.intel.com>
In-Reply-To: <20090724231511.GA20607@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Sam Ravnborg <sam@ravnborg.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Saturday 25 July 2009, Fenghua Yu wrote:
> Between GCC version 3.4.0 and 4.3.3 (including 3.4.0 and 4.3.3),
> -mtune=merced is implemented in GCC. Starting from 4.4.0, -mtune=merced
> is deprecated.
>
> Even implemented in versions between 3.4.0 and 4.3.3, the -mtune=merced
> feature has been broken in some of the versions. For example, GCC 4.1.2
> reports interanl tuning function errors during kernel building with
> -mtune=merced. Or GCC Bugzilla 16130 reports another -mtune=merced
> issue on GCC 3.4.1.
>
> So I would remove the -mtune=merced from IA64 kernel build. Without
> this option, kernel on Merced will remain the same except losing an
> unstable and out-of-date performance tunning feature.
>
> Since GCC version 3.4.0, -mtune=mckinley has been implemented. The
> -mtune=mckinley option functions the same as mtune=itanium2. And
> mtune=itanium2 is the default option. So we don't need to add
> mtune=mckinley either since its been the default option in any GCC
> version which implements this option.
>
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

Fine by me, but you'll probably want to give the commit a different 
subject :-)
