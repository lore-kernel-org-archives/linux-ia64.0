From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 04 Jan 2008 17:45:13 +0000
Subject: Re: [PATCH] ia64: cleanup header comments in mca related files
Message-Id: <200801041045.13565.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <476B3AF5.7030309@jp.fujitsu.com>
In-Reply-To: <476B3AF5.7030309@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 03 January 2008 02:48:42 pm Luck, Tony wrote:
> This looks like a nice cleanup in general (though I'm not really sure
> how much we benefit by having e-mail addresses inside <...> style
> brackets rather than parentheses :-).

I actually like that change, because then I can easily copy & paste
it into a mail composer.  I wish MAINTAINERS used that same style.

> One possible worry is this bit: 
>   * Copyright (C) 2003 Hewlett-Packard Co
> - *	David Mosberger-Tang <davidm@hpl.hp.com>
> + * Copyright (C) David Mosberger-Tang <davidm@hpl.hp.com>
> 
> While this is in the same style as all the following entries, David
> didn't explicitly claim copyright for himself with the old text, just
> for Hewlett-Packard with a following note that he made the change.
> You added the "Copyright (C)" against his name, and that doesn't
> look like a good thing to do.

I agree; I don't think we should change copyright entries.

Speaking for myself, as an employee of HP, I think my Linux work
is considered a "work made for hire," so HP is considered the
legal author for copyright purposes.  I include my name only for
"blame" purposes :-)

Bjorn
