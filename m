From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 19:50:56 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <200501061150.56776.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 11:48 am, David Mosberger wrote:
> >>>>> On Thu, 6 Jan 2005 11:42:52 -0800, Jesse Barnes
> >>>>> <jbarnes@engr.sgi.com> said:
>   >>
>   >>  Well, I don't like how you "fixed" some of them and I continue
>   >> to be of the opinion that 100 cols is OK (yes, I know that
>   >> somebody managed to get the 80 cols into the kernel formatting
>   >> document, but that doesn't change reality...).
>
>   Jesse> Yeah, I know, but your opinion is wrong :) I often find
>   Jesse> myself editing files on VTs or other 80 col terminals, and
>   Jesse> long lines are a pain...
>
> It's not opinion, it's reality.  Unless someone goes through all the
> files in the top-level directories and formats them to 80 cols, this
> won't change.

I'd be happy to do that if you're ok with it.  The long lines have always 
irritated me a little.  I think I understand why you like them though--with 
long lines you can fit slightly more code on the screen vertically, which can 
be a help, but I don't think they're common enough for that to be very 
compelling...

Jesse
