From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 16 Dec 2005 14:14:28 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <1134742468.28761.38.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com>
	 <20051215225040.GA9086@agluck-lia64.sc.intel.com>
	 <20051216010440.GA9886@agluck-lia64.sc.intel.com>
In-Reply-To: <20051216010440.GA9886@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

On Iau, 2005-12-15 at 17:04 -0800, Luck, Tony wrote:
> Being out-of-line would reduce accuracy, but this would only be
> significant when the sleep is for a very small number of microseconds.

Even then its a predicted branch to code that will probably be in cache
so really ought to have no material impact.


