From: Simon Horman <horms@verge.net.au>
Date: Thu, 08 Nov 2007 02:00:11 +0000
Subject: Re: [PATCH] Move dmi_scan_machine() call ealier
Message-Id: <20071108020009.GC831@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1194370267.31834.176.camel@bling>
In-Reply-To: <1194370267.31834.176.camel@bling>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 07, 2007 at 09:40:29AM -0700, Alex Williamson wrote:
> 
> On Wed, 2007-11-07 at 08:30 -0800, Luck, Tony wrote:
> > >   Thanks for the review Simon.  Is the patch below more like what
> > > you're thinking?  I agree that check_bugs doesn't initial seem like the
> > > most appropriate place to setup DMI, but think about what DMI is
> > > typically used for in the kernel.
> > 
> > Then re-name check_bugs() to something more suited to the things that
> > it is now doing. [I think that was what Simon was hinting at].
> 
>    Re-naming check_bugs() becomes a cross architecture endeavor.  Since
> x86 calls dmi_scan_machine() in setup_arch(), this would only be for
> ia64.  Perhaps the right answer is to make dmi_scan_machine() callable
> from setup_arch() on ia64, but that requires an safer early ioremap, and
> I'm still not sure what that should look like.  Thanks,

Yes, that does seem like a fairly substantial can of worms.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

