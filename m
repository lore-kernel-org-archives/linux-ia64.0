From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 06:19:04 +0000
Subject: [Patch 0/7] V2 Implement crashkernel=auto
Message-Id: <20090806062125.5578.72123.sendpatchset@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, Amerigo Wang <amwang@redhat.com>, akpm@linux-foundation.org, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>


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
refer patch 7/7 which contains an update for the documentation.

Note: This patchset was only tested on x86_64 with differernt memory sizes.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>

---
 Documentation/kdump/kdump.txt    |   16 ++++++++++++++++
 arch/ia64/Kconfig                |   10 ++++++++++
 arch/ia64/include/asm/kexec.h    |    8 ++++++++
 arch/powerpc/Kconfig             |   10 ++++++++++
 arch/powerpc/include/asm/kexec.h |    8 ++++++++
 arch/x86/Kconfig                 |   10 ++++++++++
 arch/x86/include/asm/kexec.h     |    1 +
 kernel/kexec.c                   |   34 ++++++++++++++++++++++++++++++++++
 8 files changed, 97 insertions(+)

