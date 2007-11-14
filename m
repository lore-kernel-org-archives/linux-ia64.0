From: Robin Holt <holt@sgi.com>
Date: Wed, 14 Nov 2007 21:12:38 +0000
Subject: Re: [PATCH] XPC heartbeat timer function must run on CPU 0
Message-Id: <20071114211238.GA14934@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
In-Reply-To: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 14, 2007 at 12:49:14PM -0800, Simon Horman wrote:
> On Thu, Nov 08, 2007 at 06:11:19AM -0600, Dean Nelson wrote:
> > On Wed, Nov 07, 2007 at 08:26:59AM -0800, Luck, Tony wrote:
> > > > Currently, XPC's heartbeat timer function runs on whatever CPU modprobe/insmod
> > > > ran on when XPC was started. To avoid the heartbeat from being delayed for
> > > > long periods the timer function must run on CPU 0.
> > > 
> > > Does Altix allow hot remove of cpu0?  If so, then you have a problem.
> > 
> > At this time Altix does not support hot remove of cpu0, but it is something
> > currently being worked on. At the time that feature is ready then this
> > code would indeed need to be modified. In the meantime, we have an existing
> > customer in need of a fix.
> 
> Kdump will run the second (crash) kernel on whatever CPU the crash
> occurs on, so its quite possible for cpu 0 not to exist in the
> second kernel. Would this be a problem for this code?

Wouldn't that cpu appear to the new OS instance as cpu0?  If so, then
it should not be an issue.

Thanks,
Robin
