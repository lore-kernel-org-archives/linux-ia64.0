From: Chris Wedgwood <cw@f00f.org>
Date: Tue, 04 May 2004 22:50:57 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <20040504225057.GA24344@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 10:51:37AM -0700, Grant Grundler wrote:

> Linux really needs a driver/card that can provide HW acceleration
> without first having BIOS initializing it. parisc-linux port
> (and probably a few others) could use such a driver/card too.

Modern hardware is complex.  The (closed) McApple firmware has
firmware to init various video cards and stufff AFAIK.  Not sure if
this is any better than BIOS emulation though.



   --cw
