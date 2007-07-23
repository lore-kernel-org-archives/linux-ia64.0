From: Doug Chapman <doug.chapman@hp.com>
Date: Mon, 23 Jul 2007 23:07:56 +0000
Subject: RE: Linus' tree broken?
Message-Id: <1185232076.7158.56.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2007-07-23 at 15:42 -0700, Luck, Tony wrote:
> > I am hitting this on my rx2620, rx6600 and rx2600 (i.e. everywhere I
> > have tried it) and the bisection is showing that it appears to have been
> > broken before -rc1.
> 
> Are you booting a generic kernel, or a zx1_defconfig based one?  Look

My config is a custom config based on the RHEL/Fedora builds.

> back in the linux-ia64 archives a few days for a post titled:
> 
>  "Regression in serial console on ia64 after 2.6.22"
> 
> Perhaps you are hitting this?

I don't think I am seeing the same thing.  My console is OK, it just
panics.  I had suspected that same patch mentioned in the post you point
to as a possible culprit but backing it out did not appear to fix my
issue.

Also, I am not passing any console= arg to the kernel and letting it
automagically determine the right thing (which is still working).

In fact I am not passing _any_ args to the kernel. perhaps that is the
difference?

- Doug


