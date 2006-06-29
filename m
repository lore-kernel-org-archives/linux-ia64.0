From: Arjan van de Ven <arjan@infradead.org>
Date: Thu, 29 Jun 2006 10:55:13 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151578513.3122.22.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>
	 <yq04py4i9p7.fsf@jaguar.mkp.net>
	 <1151578928.23785.0.camel@localhost.localdomain> <44A3AFFB.2000203@sgi.com>
In-Reply-To: <44A3AFFB.2000203@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

On Thu, 2006-06-29 at 12:48 +0200, Jes Sorensen wrote:
> Alan Cox wrote:
> > Ar Iau, 2006-06-29 am 05:37 -0400, ysgrifennodd Jes Sorensen:
> >> You have my vote for that one. Anything else is just going to cause
> >> those broken userapps to continue doing the wrong thing. We should
> >> really do this on all archs though.
> > 
> > No need, all current mainstream architectures expose a constant user HZ.
> 
Hi,

> But you are still going to have the issue where someone installs their
> own kernel and apps will break because of this?

to answer that question with one word: no.

read what Alan said: the HZ exposed to userspace is *constant*. For
example, the i386 user visible HZ is 100, even if the kernel runs at a
HZ of 250 or 1000.... Just when a HZ value gets exposed to userspace,
it's transformed into a HZ0 based value.

And that's not a distribution thing, that's the kernel.org kernel
honoring the stable-userspace-interface contract, and common sense..

Greetings,
   Arjan van de Ven

