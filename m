From: Robin Holt <holt@sgi.com>
Date: Thu, 13 Apr 2006 03:02:59 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060413030258.GA2678@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 12, 2006 at 10:22:17AM -0700, Chen, Kenneth W wrote:
> Robin Holt wrote on Wednesday, April 12, 2006 12:19 AM
> > Does the attached seem like the right direction?  I have tested it on
> > the simulator and it seems _much_ faster, but that is the simulator.
> > I have time reserved on the machine where the problem was first observed
> > later today to test it on actual hardware.
> 
> Very nice!
> 
> 
> > +		next_page_offset = ALIGN(end_address, sizeof(struct page));
> 
> ALIGN only works on power of 2 alignment, I think you would get very
> unpleasant rounding with the above.

Fixed.  I will repost the patch in a few seconds.

Thanks,
Robin Holt
