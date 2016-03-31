From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 31 Mar 2016 17:03:31 +0000
Subject: Re: [PATCH 0/11] introduce down_write_killable for rw_semaphore
Message-Id: <20160331100331.73eb381a45a1e03473f700a9@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
	<20160330133217.GV3408@twins.programming.kicks-ass.net>
	<20160331085926.GB27831@dhcp22.suse.cz>
	<20160331092005.GA18640@gmail.com>
In-Reply-To: <20160331092005.GA18640@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Thu, 31 Mar 2016 11:20:05 +0200 Ingo Molnar <mingo@kernel.org> wrote:

> So AFAIK Andrew's tree is based on top of linux-next

Not really true any more - I only base -mm patches on linux-next
patches when they must be based that way due to some known dependency.

I can certainly handle MM patches which are based on linux-next.  Such
an arrangement is going to make life awkward for Michal's
auto-maintained git tree of the -mm MM patches
(git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git).

Maybe I could merge down_write_killable into -mm's main MM section then
knock it out of my copy of linux-next, so everything is seamless for
mm.git.  I've done that before.

But it's all a bit of a pain - it would be simpler to keep
down_write_killable in the same tree as the patches which depend on it.


Michal, how about this?

mm.git currently takes the patches between

#NEXT_PATCHES_START mm
...
#NEXT_PATCHES_END


Can you change it to also take the patches between

#NEXT_PATCHES_START mm-post-next
...
#NEXT_PATCHES_END

?

That way I can do


#NEXT_PATCHES_START mm
...
#NEXT_PATCHES_END
...
linux-next.patch
revert-down_write_killable.patch
...
#NEXT_PATCHES_START mm-post-next
down_write_killlable.patch
...
#NEXT_PATCHES_END

then everything you have should apply and run OK.
