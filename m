From: Firoz Khan <firoz.khan@linaro.org>
Date: Thu, 27 Sep 2018 14:27:14 +0000
Subject: [PATCH v2 1/7] ia64: add __NR_old_getpagesize macro
Message-Id: <1538057720-3392-2-git-send-email-firoz.khan@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
In-Reply-To: <1538057720-3392-1-git-send-email-firoz.khan@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, deepa.kernel@gmail.com, marcin.juszkiewicz@linaro.org, firoz.khan@linaro.org

Add __NR_old_getpagesize in order to not break old user space
as it is reserved for backwards compatibility with old __NR_
getpagesize.

Signed-off-by: Firoz Khan <firoz.khan@linaro.org>
---
 arch/ia64/include/uapi/asm/unistd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/uapi/asm/unistd.h b/arch/ia64/include/uapi/asm/unistd.h
index 5fe71d4..4d590c9 100644
--- a/arch/ia64/include/uapi/asm/unistd.h
+++ b/arch/ia64/include/uapi/asm/unistd.h
@@ -161,7 +161,7 @@
 #define __NR_nanosleep			1168
 #define __NR_nfsservctl			1169
 #define __NR_prctl			1170
-/* 1171 is reserved for backwards compatibility with old __NR_getpagesize */
+#define __NR_old_getpagesize            1171
 #define __NR_mmap2			1172
 #define __NR_pciconfig_read		1173
 #define __NR_pciconfig_write		1174
-- 
1.9.1
