From: Arjan van de Ven <arjan@infradead.org>
Date: Wed, 28 Jun 2006 08:43:30 +0000
Subject: RE: [PATCH] ia64: change usermode HZ to 250
Message-Id: <1151484210.3153.10.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A27F855@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A27F855@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, Jeremy Higdon <jeremy@sgi.com>

On Tue, 2006-06-27 at 15:26 -0700, Luck, Tony wrote:
> > -# define HZ 1024
> > +# define HZ 250
> 
> Is every distribution just using the default 250? 

I would hope not; it's a pretty big regression for the telco space
(which really wants 1 or 2 msec delays) so I hope/assume all the
enterprise distributions (which ia64 specially cares about) stick to the
old 1024 value...


