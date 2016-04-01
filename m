From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 01 Apr 2016 07:26:54 +0000
Subject: Re: [PATCH 0/11] introduce down_write_killable for rw_semaphore
Message-Id: <20160401072653.GA8916@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
 <20160330133217.GV3408@twins.programming.kicks-ass.net>
 <20160331085926.GB27831@dhcp22.suse.cz>
 <20160331092005.GA18640@gmail.com>
 <20160331100331.73eb381a45a1e03473f700a9@linux-foundation.org>
In-Reply-To: <20160331100331.73eb381a45a1e03473f700a9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Thu 31-03-16 10:03:31, Andrew Morton wrote:
> On Thu, 31 Mar 2016 11:20:05 +0200 Ingo Molnar <mingo@kernel.org> wrote:
> 
> > So AFAIK Andrew's tree is based on top of linux-next
> 
> Not really true any more - I only base -mm patches on linux-next
> patches when they must be based that way due to some known dependency.
> 
> I can certainly handle MM patches which are based on linux-next.  Such
> an arrangement is going to make life awkward for Michal's
> auto-maintained git tree of the -mm MM patches
> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git).

Don't worry about my mmotm git tree. I will either cherry-pick these
patches from the tip or if Ingo can base them on 4.5 then I can pull
from his branch.

I was more worried about dependencies when you send your patch bomb to
Linus because then it is an additional burden on you to watch for tip
merge before you send yours.

Thanks!
-- 
Michal Hocko
SUSE Labs
