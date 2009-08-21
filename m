From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 21 Aug 2009 06:54:12 +0000
Subject: [Patch 0/8] V4 Implement crashkernel=auto
Message-Id: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

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
refer patch 8/8 which contains an update for the documentation.

Patch 1/8 implements shrinking reserved memory at run-time, which is useful
when more than enough memory is reserved automatically.

Note: This patchset was only tested on x86_64 with differernt memory sizes.

Cc: Neil Horman <nhorman@redhat.com>
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
 Documentation/kdump/kdump.txt    |   28 ++++++
 arch/ia64/Kconfig                |   14 +++
 arch/ia64/include/asm/kexec.h    |   23 ++++
 arch/powerpc/Kconfig             |   11 ++
 arch/powerpc/include/asm/kexec.h |    8 +
 arch/x86/Kconfig                 |   13 ++
 arch/x86/include/asm/kexec.h     |    1 
 include/asm-generic/kexec.h      |   42 +++++++++
 include/linux/kexec.h            |    5 +
 kernel/kexec.c                   |  180 +++++++++++++++++++++++++++++++++++++++
 kernel/ksysfs.c                  |   46 +++++++++
 11 files changed, 371 insertions(+)
