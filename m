From: Grant Grundler <iod00d@hp.com>
Date: Fri, 04 Jun 2004 23:43:01 +0000
Subject: Re: [PATCH] ia64 MAINTAINERS update
Message-Id: <20040604234301.GN11111@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406041551.25405.jbarnes@engr.sgi.com>
In-Reply-To: <200406041551.25405.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, davidm@hpl.hp.com, akpm@osdl.org, willy@debian.org

On Fri, Jun 04, 2004 at 03:51:25PM -0700, Jesse Barnes wrote:
> Dave Hansen pointed out that linux-ia64@linuxia64.org is broken.  Since the 
> list has moved and the domain is gone, update the list address and kill the 
> URL.  I think willy has a new domain for ia64 Linux, but it was down for me, 
> so I'll let him update the file later with the new URL if he wants to.

The correct URL still is:
	http://www.ia64-linux.org/

Please update the URL.

grundler <512>host www.ia64-linux.org
www.ia64-linux.org has address 192.25.206.7

192.25.206.7 also hosted parisc-linux.org.
But recently all the parisc-linux services migrated to another box.
I'm not sure when/why the "old" box was disconnected or
if it just crashed.

In any case, despite being at gcc-summit conf, willy did find time to
migrate ia64-linux.org to the same host as parisc-linux.org.
IIRC, that was yesterday. The DNS just hasn't propagated yet
but ISTR willy said it would today at some point.

The entire ia64-linux web site is available via anon CVS.
See cvs.parisc-linux.org but use "ia64-web" instead as
the repository.

I've checked out a snapshot anyone can access for now on
	http://iou.parisc-linux.org/ia64-web/

hth,
grant
