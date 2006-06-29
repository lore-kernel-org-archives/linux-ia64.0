From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 29 Jun 2006 11:34:59 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151580899.23785.7.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>
	 <yq04py4i9p7.fsf@jaguar.mkp.net>
	 <1151578928.23785.0.camel@localhost.localdomain> <44A3AFFB.2000203@sgi.com>
In-Reply-To: <44A3AFFB.2000203@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Arjan van de Ven <arjan@infradead.org>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

Ar Iau, 2006-06-29 am 12:48 +0200, ysgrifennodd Jes Sorensen:
> > No need, all current mainstream architectures expose a constant user HZ.
> 
> But you are still going to have the issue where someone installs their
> own kernel and apps will break because of this? Getting the distros to
> stop publishing a constant HZ is probably the right solution, but more
> difficult :(

Read what I said - "all current mainstream architectures expose a
constant user HZ".

The HZ used by the kernel is independant of the HZ seen for /proc etc



