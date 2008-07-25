From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 25 Jul 2008 20:30:11 +0000
Subject: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3066E990E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

        git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

[And a big thanks to Ulrich for including test programs in the
commits to x86 that added these system calls. That made testing
on ia64 a breeze]

-Tony

 arch/ia64/kernel/entry.S  |    6 ++++++
 include/asm-ia64/unistd.h |    8 +++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

Tony Luck (1):
      [IA64] Wire up new system calls



