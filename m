From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 05 May 2004 15:49:08 +0000
Subject: Re: mmap() of /dev/kmem issue
Message-Id: <40990CF4.98AF7375@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" wrote:

> >That's understandable. But there are cases where
> >kernel values just need to be read timely. As things
> >are right now you can still corrupt the kernel but
> >are unable to do anything useful because of attribute
> >aliasing to that range. Perhaps a rejection of mapping
> >such regions for writes should be imposed, but I'm
> >not sure how mapping it as uncachable helps? To
> >me this behaviour seems buggy.
>
> Mapping kernel memory as uncacheable into a user process
> seems like a recipe for disaster (well at least for an
> MCA when the processor catches you using mixed attributes).
>
> -Tony

The background on the issue is that I'm trying to mmap()
some data in KERNEL_START-KERNEL_END range
to read some data, without having to go through a system
call. This results in uncacheble mapping in
user space, which can results in what you stated above.
Its something I did routinly on other Unix variants.
And I think that restriction is not there on Linux IA32
boxes. The reason its mapped uncached its because
that range is marked reserved. I'm guessing that reserved
memory map ranges are uncachable (just guessing here),
but in this case the range in question is accessed cacheble
by the kernel.

- Mario.



