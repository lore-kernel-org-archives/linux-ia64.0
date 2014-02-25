From: AKASHI Takahiro <takahiro.akashi@linaro.org>
Date: Tue, 25 Feb 2014 09:16:23 +0000
Subject: [PATCH v2 0/1] audit: Add CONFIG_HAVE_ARCH_AUDITSYSCALL
Message-Id: <1393319784-2758-1-git-send-email-takahiro.akashi@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1391407232-4623-1-git-send-email-takahiro.akashi@linaro.org>
In-Reply-To: <1391407232-4623-1-git-send-email-takahiro.akashi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Currently AUDITSYSCALL has a long list of architecture depencency:
       depends on AUDIT && (X86 || PARISC || PPC || S390 || IA64 || UML ||
                SPARC64 || SUPERH || (ARM && AEABI && !OABI_COMPAT) || ALPHA)
The purpose of this patch is to replace it with HAVE_ARCH_AUDITSYSCALL
for simplicity.

Changes v1 -> v2:
* rebased to 3.14-rcX, and so added a change on ALPHA

AKASHI Takahiro (1):
  audit: Add CONFIG_HAVE_ARCH_AUDITSYSCALL

 arch/alpha/Kconfig     |    1 +
 arch/arm/Kconfig       |    1 +
 arch/ia64/Kconfig      |    1 +
 arch/parisc/Kconfig    |    1 +
 arch/powerpc/Kconfig   |    1 +
 arch/s390/Kconfig      |    1 +
 arch/sh/Kconfig        |    1 +
 arch/sparc/Kconfig     |    1 +
 arch/um/Kconfig.common |    1 +
 arch/x86/Kconfig       |    1 +
 init/Kconfig           |    5 ++++-
 11 files changed, 14 insertions(+), 1 deletion(-)

-- 
1.7.9.5

