From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Feb 2008 22:46:25 +0000
Subject: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC8BE677@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
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

 arch/ia64/kernel/entry.S       |    5 +-
 arch/ia64/kernel/mca.c         |   55 ++++++++--------
 arch/ia64/kernel/perfmon.c     |   21 +-----
 arch/ia64/kernel/process.c     |   59 +++++++++--------
 arch/ia64/kernel/ptrace.c      |  139 ++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/ptrace.h      |   11 +++
 include/asm-ia64/thread_info.h |   11 ++-
 include/asm-ia64/unistd.h      |    5 +-
 8 files changed, 225 insertions(+), 81 deletions(-)

Petr Tesarik (3):
      [IA64] Rename TIF_PERFMON_WORK back to TIF_NOTIFY_RESUME
      [IA64] Synchronize kernel RSE to user-space and back
      [IA64] Synchronize RBS on PTRACE_ATTACH

Russ Anderson (1):
      [IA64] Fix large MCA bootmem allocation

Tony Luck (2):
      [IA64] Wire up timerfd_{create,settime,gettime} syscalls
      [IA64] Simplify cpu_idle_wait



