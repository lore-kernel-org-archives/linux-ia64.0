From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 04 Sep 2009 10:08:20 +0000
Subject: [Patch 0/8] V6 Implement crashkernel=auto
Message-Id: <20090904101047.5220.20618.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Michael Ellerman <michael@ellerman.id.au>, Amerigo Wang <amwang@redhat.com>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


This is the LAST try, since some people still don't like them.

Please take whatever you want, patch 8/8 can be applied
seprately, only taking it is fine.


V5 -> V6:
 - move arch_default*() functions into C files.

V4 -> V5:
 - Rename the global functions, as suggested by Andrew.
 - Save some macros, as suggested by Andrew.
 - Change the high threshold, from 32G to 4G.
 - Change the low threshold on ppc, suggested by ppc developers.
 - Make the mm part as a seperate function, suggest by Eric.
 - Make the IA64 code more readable.
 - Reorder the patchset again, since review from mm people is done.

V3 -> V4:
 - Reorder the patches.
 - Really free the reserved memory, instead of remapping it.
   (Thanks to KAMEZAWA Hiroyuki!)
 - Release the reserved memory resource when the size is 0.
 - Use strict_strtoul() instead of simple_strtoul().

V2 -> V3:
 - Use more clever way to calculate reserved memory size, especially for IA64.
 - Add that patch that implements shrinking reserved memory

V1 -> V2:
 - Use include/asm-generic/kexec.h, suggested by Neil.
 - Rename a local variable, suggested by Fenghua.
 - Fix some style problems found by checkpatch.pl.
 - Unify the Kconfig docs.

This series of patch implements automatically reserved memory for crashkernel,
by introducing a new boot option "crashkernel=auto". This idea is from Neil.

In case of breaking user-space applications, it modifies this boot option after
it decides how much memory should be reserved.

On different arch, the threshold and reserved memory size is different. Please
refer patch 7/8 which contains an update for the documentation.

Patch 8/8 implements shrinking reserved memory at run-time, which is useful
when more than enough memory is reserved automatically.

This patchset _is_ already tested on x86_64, IA64 and ppc64.

Cc: Neil Horman <nhorman@redhat.com>
Cc: M. Mohan Kumar <mohan@in.ibm.com>
Cc: Michael Ellerman <michael@ellerman.id.au>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Bernhard Walle <bernhard.walle@gmx.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
 Documentation/kdump/kdump.txt       |   29 ++++++++
 arch/ia64/Kconfig                   |   14 ++++
 arch/ia64/include/asm/kexec.h       |    7 ++
 arch/ia64/kernel/machine_kexec.c    |   38 +++++++++++
 arch/powerpc/Kconfig                |   11 +++
 arch/powerpc/include/asm/kexec.h    |   22 ++++++
 arch/powerpc/kernel/machine_kexec.c |   24 ++++++
 arch/x86/Kconfig                    |   13 +++
 arch/x86/include/asm/kexec.h        |    1 
 include/asm-generic/kexec.h         |   16 ++++
 include/linux/kexec.h               |    2 
 kernel/kexec.c                      |  124 ++++++++++++++++++++++++++++++++++++
 kernel/ksysfs.c                     |   21 ++++++
 13 files changed, 322 insertions(+)

