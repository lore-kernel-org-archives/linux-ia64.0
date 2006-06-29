From: Jes Sorensen <jes@sgi.com>
Date: Thu, 29 Jun 2006 12:56:05 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <yq0veqkgly2.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>
	<yq04py4i9p7.fsf@jaguar.mkp.net>
	<1151578928.23785.0.camel@localhost.localdomain>
	<44A3AFFB.2000203@sgi.com>
	<1151578513.3122.22.camel@laptopd505.fenrus.org>
In-Reply-To: <1151578513.3122.22.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

>>>>> "Arjan" = Arjan van de Ven <arjan@infradead.org> writes:

Arjan> read what Alan said: the HZ exposed to userspace is
Arjan> *constant*. For example, the i386 user visible HZ is 100, even
Arjan> if the kernel runs at a HZ of 250 or 1000.... Just when a HZ
Arjan> value gets exposed to userspace, it's transformed into a HZ0
Arjan> based value.

Arjan> And that's not a distribution thing, that's the kernel.org
Arjan> kernel honoring the stable-userspace-interface contract, and
Arjan> common sense..

See what you mean, thanks.

Jes
