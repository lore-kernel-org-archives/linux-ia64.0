From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 01 Apr 2016 10:52:20 +0000
Subject: Re: [PATCH 0/11] introduce down_write_killable for rw_semaphore
Message-Id: <20160401105219.GD8916@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
 <20160330133217.GV3408@twins.programming.kicks-ass.net>
 <20160331085926.GB27831@dhcp22.suse.cz>
 <20160331092005.GA18640@gmail.com>
 <20160331100331.73eb381a45a1e03473f700a9@linux-foundation.org>
 <20160401063348.GA6815@gmail.com>
 <20160401092146.GC8916@dhcp22.suse.cz>
 <20160401095000.GA2487@gmail.com>
In-Reply-To: <20160401095000.GA2487@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

On Fri 01-04-16 11:50:00, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 01-04-16 08:33:48, Ingo Molnar wrote:
> > [...]
> > > I can help on the Git level: I can do tip:locking/rwsem tree with only these 
> > > changes, with stable sha1's, on which the remaining work can be based. The
> > > locking tree typically goes in early during the merge window, so there's no
> > > real dependencies.
> > 
> > OK, I will wait for this series to apear in tip:locking/rwsem and then post the 
> > follow up patches to Andrew. [...]
> 
> Well, 'this series' was posted a month ago, and patch #3 had a discussion and some 
> corrections to it - so please re-send with a v4.6-rc1 base. (v4.5 is fine too if 
> you double check that v4.6-rc1 merges cleanly with it.)

Sure will do.

Thanks!
-- 
Michal Hocko
SUSE Labs
