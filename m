From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 May 2004 15:08:21 +0000
Subject: RE: mmap() of /dev/kmem issue
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F012F267B@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4097C51D.71EA0BEA@email.mot.com>
In-Reply-To: <4097C51D.71EA0BEA@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>That's understandable. But there are cases where
>kernel values just need to be read timely. As things
>are right now you can still corrupt the kernel but
>are unable to do anything useful because of attribute
>aliasing to that range. Perhaps a rejection of mapping
>such regions for writes should be imposed, but I'm
>not sure how mapping it as uncachable helps? To
>me this behaviour seems buggy.

Mapping kernel memory as uncacheable into a user process
seems like a recipe for disaster (well at least for an
MCA when the processor catches you using mixed attributes).

-Tony
