From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 12 May 2004 21:52:22 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405121452.22556.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, May 12, 2004 2:24 pm, Jesse Barnes wrote:
> > What if stuff gets remapped etc?
>
> Then the machine takes an unrecoverable MCA, just like it does now.

Oh, actually I'm wrong here.  Since I'm looking at the physical address in the 
target identifier, a virtual remap will have no effect, so it'll still get 
caught.  Of course, that only addresses one of your concerns...

Jesse
