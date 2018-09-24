From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 24 Sep 2018 14:20:32 +0000
Subject: [REVIEW][PATCH 0/3] signal/ia64: siginfo fixes and cleanups
Message-Id: <87bm8n2czz.fsf@xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>


I have been slowly cleaning up the architectues ever since I discovered
that the pattern of passing in struct siginfo is error prone, and
occassionally results in borken siginfo being sent to userspace.

It turns out that ia64 is one of the noticable offenders.  Ever since
ia64 was merged in 2.3.43 it has been generating incorrect siginfo for
SIGSEGV assocaited with the inability to setup a signal stack frame
or cleanup a signal stack frame.

This is pretty esoteric case and the problem was only some values that
should be 0 being something else so I am not surpised it was missed.

The following series fixes the two buggy cases I have found and then
cleans up replaces force_sig_info with force_sig_fault to avoid errors
of this kind in the future.

I don't think I have made made any mistakes in this coversion but if
people can look the code over and see if they can spot anything I would
appreciate it.

My intention is to merge this through my siginfo tree.  If you feel it
should go through your arch tree let me know.   All of the prerequisites
should have been merged several releases ago.

Eric W. Biederman (3):
      signal/ia64: Use the generic force_sigsegv in setup_frame
      signal/ia64: Use the force_sig(SIGSEGV,...) in ia64_rt_sigreturn
      signal/ia64: Use force_sig_fault where appropriate

 arch/ia64/kernel/brl_emu.c   |  31 ++--------
 arch/ia64/kernel/signal.c    |  60 ++++--------------
 arch/ia64/kernel/traps.c     | 144 ++++++++++++-------------------------------
 arch/ia64/kernel/unaligned.c |  12 +---
 arch/ia64/mm/fault.c         |  12 +---
 5 files changed, 62 insertions(+), 197 deletions(-)

Eric
