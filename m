From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 04 Mar 2004 15:47:27 +0000
Subject: Re: [PATCH] more robust halt_light
Message-Id: <1078415247.2504.3.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-03-03 at 15:56, Jesse Barnes wrote:
> On Wed, Mar 03, 2004 at 02:45:11PM -0800, David Mosberger wrote:
> > Can we get rid of the CONFIG option too?  Or do folks who care (too?)
> > much about wake-up latency prefer to turn off a CONFIG option over
> > booting with nohlt?
> 
> Some people have come to me concerned about the wakeup latency of having
> the halt call in there, and it also looks like the PAL has a bug on our
> platform that causes hangs when we call PAL_HALT_LIGHT (which we're
> tracking down), so I wouldn't mind if the config option stuck around a
> little longer (or was a boot time parameter at least).

Jesse,

    Perhaps sn specific code (maybe sn_setup) could call disable_hlt()
until you're comfortable leaving it on by default.  Requiring a boot
time command like option on your platform sounds error prone.

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

