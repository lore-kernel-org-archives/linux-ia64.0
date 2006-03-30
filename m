From: Keith Owens <kaos@sgi.com>
Date: Thu, 30 Mar 2006 09:14:47 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <15307.1143710087@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen (on 30 Mar 2006 03:57:04 -0500) wrote:
>>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:
>
>>> I also tried yesterday's snapshot 2.6.16-git17 on my tiger4, it
>>> doesn't boot :-(
>>> 
>>> So far we have reports on:
>>> 
>>> (1) 2.6.16.1 doesn't boot on altix (2) 2.6.16-git17 doesn't boot on
>>> tiger4 (3) Jes's strange .section causing some hangs.
>
>Tony> Tiger still boots with my release tree (just has seven patches
>Tony> that haven't been sent to Linus yet, including Russ' fix for my
>Tony> merge goof that created item "3" above).  I haven't pulled in
>Tony> from Linus in about three days, so I'm about 458 commits behind
>Tony> the bleeding edge.  So a "git bisect" between Linus head and the
>Tony> point where I last merged (commit 64bc0430) might yield the
>Tony> problem (for Ken's tiger boot issue).
>
>Tony,
>
>Please note that if I compile the kernel on a box with an old
>installation and old toolchain the kernel boots, same source tree
>built on a system with a new installation and it doesn't boot.

This sounds like a random data overwrite which depends on the exact
kernel layout.  Somebody else in SGI (Prarit ?) said that they compiled
your failing tree on the same platform and their kernel worked.  Since
the build userid and the pathname to the kernel source tree are
embedded in the binary, changing either of those will disturb the
kernel layout, possibly making the problem move.

Jes, try renaming your source tree to something with a different
pathname length and rebuild the kernel.  Does the problem change or go
away?

