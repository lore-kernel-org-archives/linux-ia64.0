From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 23 Feb 2004 21:09:20 +0000
Subject: Re: SAL version checking
Message-Id: <20040223210920.GA8433@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 09:01:05PM +0000, Matthew Wilcox wrote:
> +int sal_check_version(int major, int minor)
> +{
> +       if (major < sal_rev_major)
> +               return 1;
> +       if (major > sal_rev_major)
> +               return 0;
> +       return (sal_rev_minor >= minor);
>  }
> 
> 
> Anyone want to propose a different solution?

It looks reasonable to me, though I thought we were the only ones that
cared about PROM revisions ;).  If you go ahead and push this in, we
could use it in arch/ia64/sn/kernel/setup.c, where we check for
incompatibilties bad enough to cause us to bail out...

Jesse
