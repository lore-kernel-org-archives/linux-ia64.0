From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 21:54:40 +0000
Subject: Re: fixing 2.6.10 UP builds
Message-Id: <200501061354.40921.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106201427.GA6009@jale>
In-Reply-To: <20050106201427.GA6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 1:31 pm, Luck, Tony wrote:
> >Debian is putting together 2.6.10 packages, and we noticed
> >that we still need to forward port Jesse's patches.  Attached is the patch
> >Ubuntu forward ported, and Debian is including.  It would be great to get
> >this merged upstream so we don't need to port it for each release.
>
> 2.6.10 built as UP for me (I have it running on zx2000).

A zx1 specific kernel?  Most of these changes are NUMA and discontig specific, 
so they apply more to generic kernels than particular types.

Jesse
