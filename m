From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 20:07:57 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <200501061207.57741.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 12:00 pm, David Mosberger wrote:
> >>>>> On Thu, 6 Jan 2005 11:50:56 -0800, Jesse Barnes
> >>>>> <jbarnes@engr.sgi.com> said:
>   >>
>   >>  It's not opinion, it's reality.  Unless someone goes through all
>   >> the files in the top-level directories and formats them to 80
>   >> cols, this won't change.
>
>   Jesse> I'd be happy to do that if you're ok with it.
>
> Eh, I'm talking about linux/kernel/* etc, so it's really Andrew and
> Linus who'd have to be OK with it.
>
> If you can fix those, I'd be happy to adjust the ia64 files to fit
> within 80 cols.

Really?  In my experience the core files are generally pretty good (every now 
and then a long line creeps in, but there aren't that many that I can see).  
Any big offenders that really bug you?

> I don't particularly like 100 cols.  I'd be happy if all (major) Linux
> kernel files fit into 80 cols, it's just that in reality, you need 100
> cols to look at most important kernel files.

Well if you don't like them either (that makes none that I know of), shouldn't 
we at least fixup the ia64 bits, regardless of what happens with the core 
kernel files?

Jesse
