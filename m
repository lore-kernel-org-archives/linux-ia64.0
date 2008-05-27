From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 May 2008 23:26:45 +0000
Subject: RE: [PATCH 00/17] ia64/pv_ops take 6
Message-Id: <1FE6DD409037234FAB833C420AA843EC016FF410@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12112028241775-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12112028241775-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Thank you for testing.
>
> What was the result?

No problems found.

> No patch has been committed to
> git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test

I had to spend time on a bugfix.  The bugfix is posted
in my 'release' branch. The pv_ops series (including the
documentation) is now in the 'test' branch.  Take a close
look at arch/is64/kernel/minstate.h as I had to re-merge
your changes because of collisions with the bugfix.

-Tony
