From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 06 Jan 2005 20:01:44 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <20050106200144.GN27371@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 06, 2005 at 11:48:19AM -0800, David Mosberger wrote:
> >>>>> On Thu, 6 Jan 2005 11:42:52 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:
> 
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

Personally, I don't mind it too much when code wraps a little bit.
But the comments wrapping after 80 columns *really* bugs me.  Probably
because code has to read slower than prose anyway.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
