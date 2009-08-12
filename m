From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 12 Aug 2009 08:15:09 +0000
Subject: [Patch 0/8] V3 Implement crashkernel=auto
Message-Id: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


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

Patch 8/8 implements shrinking reserved memory at run-time.

Note: This patchset was only tested on x86_64 with differernt memory sizes.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Bernhard Walle <bernhard.walle@gmx.de>

---
 Documentation/kdump/kdump.txt    |   28 ++++++++++
 arch/ia64/Kconfig                |   14 +++++
 arch/ia64/include/asm/kexec.h    |   23 ++++++++
 arch/powerpc/Kconfig             |   11 ++++
 arch/powerpc/include/asm/kexec.h |    8 +++
 arch/x86/Kconfig                 |   13 ++++
 arch/x86/include/asm/kexec.h     |    1 
 include/asm-generic/kexec.h      |   42 +++++++++++++++
 include/linux/kexec.h            |    3 +
 kernel/kexec.c                   |  104 +++++++++++++++++++++++++++++++++++++++
 kernel/ksysfs.c                  |   21 +++++++
 11 files changed, 268 insertions(+)
