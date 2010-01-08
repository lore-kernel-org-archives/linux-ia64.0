From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jan 2010 17:20:40 +0000
Subject: [git pull] ia64 changes
Message-Id: <4b47696840264bbfa@agluck-desktop.sc.intel.com>
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

-Tony

 arch/ia64/include/asm/ftrace.h   |    1 -
 arch/ia64/include/asm/kprobes.h  |    5 -----
 arch/ia64/include/asm/tlb.h      |    2 +-
 arch/ia64/include/asm/topology.h |    4 +++-
 arch/ia64/include/asm/types.h    |    5 +++++
 arch/ia64/kernel/mca.c           |    5 ++++-
 arch/ia64/kernel/perfmon.c       |    2 +-
 arch/ia64/mm/init.c              |    2 +-
 arch/ia64/mm/tlb.c               |   32 +++++++++++++++++++-------------
 9 files changed, 34 insertions(+), 24 deletions(-)

Anton Blanchard (1):
      [IA64] cpumask_of_node() should handle -1 as a node

Jiri Slaby (1):
      [IA64] use helpers for rlimits

Tony Luck (2):
      [IA64] sanity in #include files.  Move fnptr to types.h
      [IA64] __per_cpu_idtrs[] is a memory hog

