From: john stultz <johnstul@us.ibm.com>
Date: Thu, 29 Jul 2004 17:02:11 +0000
Subject: Re: [PATCH] minor cyclone cleanup
Message-Id: <1091120530.6094.8.camel@leatherman.cornchips.homelinux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407291054.05720.bjorn.helgaas@hp.com>
In-Reply-To: <200407291054.05720.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2004-07-29 at 09:54, Bjorn Helgaas wrote:
> Trivial cleanup.  BTW, the ia64 cyclone code has no copyright or license.

Looks good to me! If a copyright/license message is necessary, I can
create a patch for you. 

> There's also an arch/i386/kernel/timers/timer_cyclone.c that looks
> suspiciously similar, and few if any actual architecture dependencies
> in either the i386 or the ia64 files.  Why are they different?

Indeed, they are very similar, but because the timeofday subsystems are
so different in each arch I implemented it separately. 

I hope to fix this in 2.7/2.6 (whatever) by merging all the arch
specific timeofday code into one arch independent implementation. Then
just a single time-source driver will be needed for both arches (ACPI PM
and HPET will additionally be able to be shared). 

Stay tuned! As soon as I finish reworking the NTP code bI'll be mailing
out code. 

> Make cyclone_setup() take no args, rather than an ignored "char *"
> and return void.  Fix typos and whitespace.

Apologies for the mess, thanks for cleaning that up!

thanks again, 
-john

