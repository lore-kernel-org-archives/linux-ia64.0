From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 03 Dec 2004 18:00:09 +0000
Subject: Re: memccpy() gives inconsistent results on mmapped files
Message-Id: <20041203180009.GA12808@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9880.1102044614@kao2.melbourne.sgi.com>
In-Reply-To: <9880.1102044614@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Dec 03, 2004 at 07:22:41AM -0500, Jeff Hanson wrote:
> Christoph Hellwig wrote:
> >On Fri, Dec 03, 2004 at 02:30:14PM +1100, Keith Owens wrote:
> >
> >>Glenn Fowler of ATT reported that memccpy() gives inconsistent results
> >>on mmapped files.  This was reported to SGI, but the bug is ia64
> >>generic, I get the same errors on a vanilla ia64 box.
> >>
> >>Glenn's test case follows, it has been tweaked to add a PREFAULT
> >>option.  Prefaulting the input file makes memccpy work.  The problem
> >>occurs on both glibc 2.2.4 and glibc 2.3.3.
> >
> >
> >Didn't Jes fix that long ago in SGIs glibc?
> 
> Yes he did.  For exactly the same customer with the same test code.

Can someone send me a patch?

Thanks.


H.J.
