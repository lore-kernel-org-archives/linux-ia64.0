From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 03 Feb 2005 15:15:01 +0000
Subject: Default preempt_count setting
Message-Id: <20050203151501.GC20386@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I noticed that almost every architecture has some variant of:

#define INIT_THREAD_INFO(tsk)                   \
[...]
        .preempt_count  = 1,                    \

except for parisc, ia64 and arm26.  parisc and arm26 don't have functional
PREEMPT, so I suspect can simply be changed.  How about ia64 though?
I see PREEMPT is available as an option ... should preempt_count be
initialised to 1 on ia64?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
