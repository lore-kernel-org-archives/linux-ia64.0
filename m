From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Apr 2008 23:51:01 +0000
Subject: [git pull] ia64 changes
Message-Id: <1FE6DD409037234FAB833C420AA843EC012F9EF0@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Mike Travis <travis@sgi.com>, Russ Anderson <rja@sgi.com>

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below. Both changes touch kernel/sched.c
to fix regressions ... one for a build problem, the other for a boot
problem.

Thanks!

-Tony

 kernel/sched.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

Mike Travis (1):
      Build fix for CONFIG_NUMA=y && CONFIG_SMP=n

Russ Anderson (1):
      [IA64] fix bootmem regression on Altix



