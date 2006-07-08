From: Jeremy Higdon <jeremy@sgi.com>
Date: Sat, 08 Jul 2006 00:14:27 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <20060708001427.GA723842@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com> <yq04py4i9p7.fsf@jaguar.mkp.net> <1151578928.23785.0.camel@localhost.localdomain> <44A3AFFB.2000203@sgi.com> <1151578513.3122.22.camel@laptopd505.fenrus.org>
In-Reply-To: <1151578513.3122.22.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Jes Sorensen <jes@sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>

On Thu, Jun 29, 2006 at 12:55:13PM +0200, Arjan van de Ven wrote:
> On Thu, 2006-06-29 at 12:48 +0200, Jes Sorensen wrote:
> > Alan Cox wrote:
> > > Ar Iau, 2006-06-29 am 05:37 -0400, ysgrifennodd Jes Sorensen:
> > >> You have my vote for that one. Anything else is just going to cause
> > >> those broken userapps to continue doing the wrong thing. We should
> > >> really do this on all archs though.
> > > 
> > > No need, all current mainstream architectures expose a constant user HZ.
> > 
> Hi,
> 
> > But you are still going to have the issue where someone installs their
> > own kernel and apps will break because of this?
> 
> to answer that question with one word: no.
> 
> read what Alan said: the HZ exposed to userspace is *constant*. For
> example, the i386 user visible HZ is 100, even if the kernel runs at a
> HZ of 250 or 1000.... Just when a HZ value gets exposed to userspace,
> it's transformed into a HZ0 based value.
> 
> And that's not a distribution thing, that's the kernel.org kernel
> honoring the stable-userspace-interface contract, and common sense..


So does i386 convert the return value of the times(2) call to user
hertz?  On IA64, it returns the value in internal clock ticks, and
then when a program uses the value in param.h, it gets it wrong now,
because internal HZ is now 250.

So is times() is broken in IA64, or is this an exception to Alan's
statement?

jeremy
