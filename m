From: Matthew Wilcox <willy@debian.org>
Date: Thu, 12 Feb 2004 22:08:20 +0000
Subject: Re: How do I raise a thread to realtime priority?
Message-Id: <20040212220820.GG31168@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040212215357.GA15214@lnx-holt>
In-Reply-To: <20040212215357.GA15214@lnx-holt>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 12, 2004 at 03:53:57PM -0600, Robin Holt wrote:
> In the 2.4 kernel headers, unistd.h had a _syscall3 that I could
> use to make an extern of the sys_sched_setscheduler raise a tasks
> priority to realtime.  With 2.6, the _syscall3 has been replaced
> with static inlines.  This all seems well.
> 
> Since sys_sched_setscheduler is not in the unistd.h, should I add
> it to unistd.h?  Is there a prefered method for exporting/inlining
> syscall entry points?

libc "exports syscall entry points" -- call sched_setscheduler().
That works on 2.4 and 2.6.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
