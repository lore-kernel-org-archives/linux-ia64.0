From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 06 Jan 2005 20:10:55 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <20050106201055.GO27371@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 06, 2005 at 12:00:11PM -0800, David Mosberger wrote:
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

$ echo `for i in kernel/*.c; do expand $i |grep -c -E '^.{81,}$'; done`
0 0 0 3 7 5 0 0 0 0 15 0 12 0 4 1 6 0 0 0 0 0 3 1 2 0 4 13 1 4 0 11 19 11 2
0 0 22 0 9 4 12 4 2 1 1
$echo `for i in arch/ia64/kernel/*.c; do expand $i |grep -c -E '^.{81,}$'; done`
4 31 62 6 6 0 191 3 2 52 15 7 0 3 79 19 108 53 16 398 15 47 183 1 27 0 43 87
18 36 19 22 44 110 176 0

Very few exceptions to the 80-column rule in kernel/*.c.  A ridiculous
number of exceptions in arch/ia64/kernel/*.c.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
