From: Jes Sorensen <jes@sgi.com>
Date: Thu, 30 Mar 2006 08:57:04 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <yq0y7ysux7j.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

>> I also tried yesterday's snapshot 2.6.16-git17 on my tiger4, it
>> doesn't boot :-(
>> 
>> So far we have reports on:
>> 
>> (1) 2.6.16.1 doesn't boot on altix (2) 2.6.16-git17 doesn't boot on
>> tiger4 (3) Jes's strange .section causing some hangs.

Tony> Tiger still boots with my release tree (just has seven patches
Tony> that haven't been sent to Linus yet, including Russ' fix for my
Tony> merge goof that created item "3" above).  I haven't pulled in
Tony> from Linus in about three days, so I'm about 458 commits behind
Tony> the bleeding edge.  So a "git bisect" between Linus head and the
Tony> point where I last merged (commit 64bc0430) might yield the
Tony> problem (for Ken's tiger boot issue).

Tony,

Please note that if I compile the kernel on a box with an old
installation and old toolchain the kernel boots, same source tree
built on a system with a new installation and it doesn't boot.

Cheers,
Jes
