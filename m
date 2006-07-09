From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 09 Jul 2006 19:18:21 +0000
Subject: RE: [PATCH] ia64: change usermode HZ to 250
Message-Id: <617E1C2C70743745A92448908E030B2A34B9BD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060627220139.3168.69409.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>, Jeremy Higdon <jeremy@sgi.com>
Cc: Jes Sorensen <jes@sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, John Daiker <jdaiker@osdl.org>, John Hawkes <hawkes@sgi.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>

> > So is times() is broken in IA64, or is this an exception to Alan's
> > statement?

> yes it's broken; it needs to convert it to the original HZ (1024) and


http://www.opengroup.org/onlinepubs/007908799/xsh/times.html

In which there is a typo: 

"Applications should use to determine the number of clock ticks
 per second as it may vary from system to system"

Clearly the word "sysconf" is missing between "use" and "to" (sysconf()
*is* listed in the SEE ALSO section).

I thought that part of the reason Linus raised HZ from 100 to 1000
on x86 was to help flush out pre-historic programs that didn't
know about sysconf() [With the hope that results that are off by
an order of magnitude would be absurd enough to get notice].

> make the sysconf() function also return 1024

Making sysconf lie about the actual system tick sounds such a
bad idea on so many levels!

-Tony
