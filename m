From: Jason Baron <jbaron@redhat.com>
Date: Mon, 17 Jan 2005 18:32:15 +0000
Subject: Re: [patch] add BUG call to overlapping vma fix
Message-Id: <Pine.LNX.4.44.0501171324430.11137-100000@dhcp83-105.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501141131310.12942-200000@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0501141131310.12942-200000@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 14 Jan 2005, Arun Sharma wrote:

> On 1/14/2005 8:52 AM, Jason Baron wrote:
> > hi,
> > 
> > It seems that in ia64_elf32_init, instead of calling return, if we insert
> > an overlapping vma, we should instead BUG(). We should never get into this
> > code path, because the vma's are set above PAGE_OFFSET, and thus a
> > Xmalicious user can not trigger this code path. This change is being
> > suggested mainly for clarity. Thanks to Stephen Tweedie for pointing out
> > that returning early in ia64_elf32_init could have unpredictable results.
> > 
> 
> Couldn't you get rid of a couple of more lines before the BUG()? Otherwise, the patch looks good to me.
> 
> 	-Arun
> 
> 

It kind of makes sense to free the vma, since its not linked in yet, 
and thus wouldn't be freed up via exit_mm. However, i don't really have a 
strong preference either way

-Jason

