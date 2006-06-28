From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 28 Jun 2006 10:34:03 +0000
Subject: RE: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151490843.3153.28.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27F855@scsmsx411.amr.corp.intel.com>
	 <1151484210.3153.10.camel@laptopd505.fenrus.org>
	 <1151491677.15166.13.camel@localhost.localdomain>
In-Reply-To: <1151491677.15166.13.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Luck, Tony" <tony.luck@intel.com>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

On Wed, 2006-06-28 at 11:47 +0100, Alan Cox wrote:
> Ar Mer, 2006-06-28 am 10:43 +0200, ysgrifennodd Arjan van de Ven:
> > I would hope not; it's a pretty big regression for the telco space
> > (which really wants 1 or 2 msec delays) so I hope/assume all the
> > enterprise distributions (which ia64 specially cares about) stick to the
> > old 1024 value...
> 
> 250 is also really bad for multimedia people. They would much rather
> have 300 than 250 as it divides nicely by 50 and by 60 for frame rates.

yup I know; I proposed that back when this was discussed but lost that
argument ;(

