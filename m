From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 04 Mar 2004 02:40:41 +0000
Subject: RE: [PATCH] more robust halt_light
Message-Id: <01EF044AAEE12F4BAAD955CB75064943010F08FF@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



>-----Original Message-----
>From: Jesse Barnes [mailto:jbarnes@sgi.com]
>Sent: Wednesday, March 03, 2004 2:56 PM
>To: davidm@hpl.hp.com
>Cc: Alex Williamson; Seth, Rohit; linux-ia64
>Subject: Re: [PATCH] more robust halt_light
>
>On Wed, Mar 03, 2004 at 02:45:11PM -0800, David Mosberger wrote:
>> Can we get rid of the CONFIG option too?  Or do folks who care (too?)
>> much about wake-up latency prefer to turn off a CONFIG option over
>> booting with nohlt?
>
>Some people have come to me concerned about the wakeup latency of
having
>the halt call in there, and it also looks like the PAL has a bug on our
>platform that causes hangs when we call PAL_HALT_LIGHT (which we're
>tracking down), so I wouldn't mind if the config option stuck around a
>little longer (or was a boot time parameter at least).
>
>Thanks,
>Jesse

As far as latency is concerned, do you have any specific workload that
is getting impacted (severly) by this transition.  

I think we should remove the compile time CONFIG_OPTION for
PAL_HALT_LIGHT.  And instead use /proc interface to dynamically
enable/disable the power transition.
