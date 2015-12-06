From: Li Bin <huawei.libin@huawei.com>
Date: Sun, 06 Dec 2015 02:02:53 +0000
Subject: [PATCH v2 0/5] ftrace: fix ftrace misleading comments for arch using it
Message-Id: <1449367378-29430-1-git-send-email-huawei.libin@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, Li Bin <huawei.libin@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, James Hogan <james.hogan@imgtec.com>, linux-metag@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org

Fix the following similar misleading comments of ftrace for arch
ia64/metag/powerpc/sh/x86:

Note: Due to modules and __init, code can
 disappear and change, we need to protect against faulting
 as well as code changing. We do this by using the
 probe_kernel_* functions.

No real locking needed, this code is run through
kstop_machine, or before SMP starts.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Cc: James Hogan <james.hogan@imgtec.com>
Cc: linux-metag@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au> 
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-sh@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
"Cc: H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org

Li Bin (5):
  ia64: ftrace: fix the comments for ftrace_modify_code
  metag: ftrace: fix the comments for ftrace_modify_code
  powerpc: ftrace: fix the comments for ftrace_modify_code
  sh: ftrace: fix the comments for ftrace_modify_code
  x86: ftrace: fix the comments for ftrace_modify_code_direct

 arch/ia64/kernel/ftrace.c    |   12 +++++-------
 arch/metag/kernel/ftrace.c   |   11 +++++------
 arch/powerpc/kernel/ftrace.c |   12 +++++-------
 arch/sh/kernel/ftrace.c      |   12 +++++-------
 arch/x86/kernel/ftrace.c     |   12 +++++-------
 5 files changed, 25 insertions(+), 34 deletions(-)

