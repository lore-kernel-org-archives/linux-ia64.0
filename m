From: Robin Holt <holt@sgi.com>
Date: Mon, 06 Oct 2003 18:18:21 +0000
Subject: Re: [PATCH] kill sn_ksyms.c
Message-Id: <marc-linux-ia64-106546439321173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451999732538@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451999732538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Oct 05, 2003 at 01:47:05PM -0700, Jesse Barnes wrote:
> On Sun, Oct 05, 2003 at 12:33:00PM -0400, Jes Sorensen wrote:
> > >>>>> "Christoph" = Christoph Hellwig <hch@lst.de> writes:
> > 
> > Christoph> None of the exported symbols is referenced by a module,
> > Christoph> even more the file doesn't compile shen
> > Christoph> CONFIG_IA64_SGI_SN_DEBUG is set.
> > 
> > There are some device drivers coming that will depend on some of these
> > symbols so I'd prefer to keep this file in place, at least for
> > now. And yes, said drivers are GPL'ed.
> 
> Or just move that stuff when we submit the drivers.  I think Robin
> looked at this a bit...

I thought the sn_ksyms was already gone in 2.6.  I would say, go ahead
and remove it.  We will include our EXPORT_SYMBOLs for the symbols
we need at that time.

For 2.4, I guess I would say it isn't worth messing with.

Robin
