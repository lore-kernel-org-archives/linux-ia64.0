From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 14 Apr 2016 19:59:38 +0000
Subject: [PATCH 0/3] Initial Kexec patches
Message-Id: <20160414195938.GV19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Biederman <ebiederm@xmission.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, kexec@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

Eric,

Here are some initial patches from my stack to bring functional kexec
support to the TI Keystone 2 platform.  These are relatively independent
of that work, but I believe are useful changes in their own regard.
Each patch is independent of each other; these do not really comprise
a strict series.

The first fixes an obscure problem - if we try to allocate the control
page, and we're unable to allocate a page within the memory region we
want, we end up killing processes, trying to gain that page.  In the
case where there is no memory located within the desired range, this
results in the OOM killer killing off many processes rather than a
graceful failure.  The patch changes the behaviour to allow a graceful
failure instead without invoking the OOM killer.

The second patch fixes a missing check in the kexec code, where the
user could supply a start and size address for a segment which causes
the calculation to wrap.  Eg, the case where segment[0].mem = 0xffff0000,
segment[0].memsz = 0x10000 would pass this check.  This patch adds an
explicit check for cases such as these.

The third patch allows the vmcoreinfo note data to be located above
4GB in physical memory space.  Since kexec tools only use this value
when opening /dev/mem, having this located above 4GB physical is not
a problem - kexec tools even expect this to potentially be a 64-bit
value already.  Making this change means there is one less area which
becomes Keystone 2 specific.

 arch/ia64/kernel/machine_kexec.c | 2 +-
 include/linux/kexec.h            | 4 ++--
 kernel/kexec_core.c              | 4 +++-
 kernel/ksysfs.c                  | 4 ++--
 4 files changed, 8 insertions(+), 6 deletions(-)

Thanks.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
