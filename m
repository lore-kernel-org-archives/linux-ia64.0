From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 10 Sep 2004 15:34:27 +0000
Subject: Re: [RFC 0/4] Add SN2 Special Memory driver.
Message-Id: <200409100834.27375.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, September 10, 2004 1:32 am, Christoph Hellwig wrote:
> > Do any other processors have the write combining features of the ia64? 
> > Is this type of memory useable by any other processor?  If not, does this
> > driver belong in the arch/ia64/kernel directory?
>
> Umm, yes I guess it'll be ia64-specific at least as a start,  I just wanted
> to avoid having it SN2-specific.

...but if it's a char driver, just put it in drivers/char.  Makes it easier to 
update APIs and such that way.

Jesse
