From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 02 Mar 2005 17:21:43 +0000
Subject: Re: [PATCH 2.6.11-rc3 1/1] altix: Device driver support for the CX port of SGI's TIO chip
Message-Id: <200503020921.43626.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050228235822.16768.33715.29715@attica.americas.sgi.com>
In-Reply-To: <20050228235822.16768.33715.29715@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, March 1, 2005 8:47 pm, Christoph Hellwig wrote:
> (care to split this into a two-patch series for the next submission,
> one for tiocx, one for mbcs?)
>
> > +obj-$(CONFIG_SGI_TIOCX)  += tiocx.o
>
> this one should really be in arch/ia64/sn/

Even though it's a char driver?  I told him to put it in drivers/char to make 
API change sweeps a bit easier...  Fine with me if it ends up in arch/ia64/sn 
though.

Jesse
