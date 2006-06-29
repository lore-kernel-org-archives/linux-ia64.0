From: Jes Sorensen <jes@sgi.com>
Date: Thu, 29 Jun 2006 10:48:27 +0000
Subject: Re: [PATCH] ia64: change usermode HZ to 250
Message-Id: <44A3AFFB.2000203@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27FC5F@scsmsx411.amr.corp.intel.com>	 <yq04py4i9p7.fsf@jaguar.mkp.net> <1151578928.23785.0.camel@localhost.localdomain>
In-Reply-To: <1151578928.23785.0.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Luck, Tony" <tony.luck@intel.com>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Arjan van de Ven <arjan@infradead.org>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

Alan Cox wrote:
> Ar Iau, 2006-06-29 am 05:37 -0400, ysgrifennodd Jes Sorensen:
>> You have my vote for that one. Anything else is just going to cause
>> those broken userapps to continue doing the wrong thing. We should
>> really do this on all archs though.
> 
> No need, all current mainstream architectures expose a constant user HZ.

But you are still going to have the issue where someone installs their
own kernel and apps will break because of this? Getting the distros to
stop publishing a constant HZ is probably the right solution, but more
difficult :(

Cheers,
Jes
