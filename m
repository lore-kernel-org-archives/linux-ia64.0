From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 08 Jun 2007 02:22:15 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.LNX.4.64.0706071920460.26230@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 8 Jun 2007, Boehm, Hans wrote:

> This of course causes problems for applications that try to use page
> protection to track updates or are relying on small granularity
> copy-on-write, or the like.  Anything that uses our garbage collector in
> incremental mode will fit that description, though I don't believe there
> are currently many such applications.  Checkpointing may be another

Why is that a problem? The granularity would change right?

> similar issue, at least for some applications.  Software DSM
> implementations would clearly be affected.  I would guess that the trend
> is likely to be towards more of this in all three of those areas.

Which?

> I am not really arguing against this, since I don't have a good overview
> of how many customers are likely to be affected.  I just want to make
> sure that both sides of the issue are considered.

SLES9 is available in a 64k page size version. Some customers still run 
that one because it is faster.

