From: Jes Sorensen <jes@sgi.com>
Date: Tue, 24 Jul 2007 08:50:26 +0000
Subject: Re: Linus' tree broken?
Message-Id: <46A5BD52.5070908@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Doug Chapman wrote:
> 
> It appears to have something to do with grabbing the kernel args.  The
> panic happens here:
> 
> 0xa0000001007f1511 is in setup_arch (arch/ia64/kernel/setup.c:570).
> 565
> 566             /* enable IA-64 Machine Check Abort Handling unless disabled
> */
> 567             if (!nomca)
> 568                     ia64_mca_init();
> 569
> 570             platform_setup(cmdline_p);
> 571             paging_init();
> 572     }

Doug,

I see the exact same OOPS if I compile a generic kernel instead of an
SN2 specific one.

Cheers,
Jes
