From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 18:07:41 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405041107.41062.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 10:43 am, David Mosberger wrote:
> Eh, I/O space is required to soft-fail, isn't it?

I thought so too, but I haven't been able to find the spec that contains that 
requirement.

> Why can't you hide this in the platform-specific inX/outX routines?  I
> suppose it would be very slow to drain MCAs after every inX/outX, but
> you'd have to do the slow part only once, until you know whether or
> not the given I/O address is safe.

This is I/O initiated by userspace loads/stores, so unless I wrap every in/out 
with some sort of ioctl or something, those won't help me.  Also, with this 
scheme, we could potentially recover from regular read/writes too.

Jesse
