From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 16 Jan 2004 02:21:55 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040116022155.GA10634@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com> <20040116003224.GF23253@kroah.com>
In-Reply-To: <20040116003224.GF23253@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeremy@sgi.com

On Thu, Jan 15, 2004 at 04:32:25PM -0800, Greg KH wrote:
> It looks ok, but it would really be good if we could indicate if the
> read actually was successful.  Right now some platforms can detect
> faults and do not have a way to get that error back to the driver in a
> sane manner.  If we were to change the read* functions to look something
> like:
> 	int readb(void *addr, u8 *data);
> it would be a world easier.

At one point, I thought it would be nice if it took a struct device *
too, but that's probably a bit much.

> Now I'm not saying I want to change the existing interfaces to support
> this, that's too much code to change for even me (and is a 2.7 thing.)
> 
> Just wanted to put this idea in people's heads that we need to start
> planning for something like it.

Sounds reasonable.  It should be helpful.

Thanks,
Jesse
