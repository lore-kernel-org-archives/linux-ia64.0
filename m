From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 05 May 2004 14:57:41 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <409900E5.B7A8AEC7@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

> On Tue, May 04, 2004 at 05:27:41PM -0500, Mario Smarduch wrote:
> > I would think allot of people would like to mmap() /dev/kmem
> > to take a quick look at kernel values, atleast that's what I've
> > seen on other Unix variants.
>
> yes - and that's a religious issue. I know people would
> like like to see /dev/kmem completely removed.
>
> Many wise kernel engineers have advised me to add /proc
> or similar "architected" interfaces. That way a program
> will merely get an error instead of crashing the box
> when the kernel changes it's data structures or how said
> structures get used.
>
> grant

That's understandable. But there are cases where
kernel values just need to be read timely. As things
are right now you can still corrupt the kernel but
are unable to do anything useful because of attribute
aliasing to that range. Perhaps a rejection of mapping
such regions for writes should be imposed, but I'm
not sure how mapping it as uncachable helps? To
me this behaviour seems buggy.

- Mario.

