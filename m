From: Linus Walleij <linus.walleij@linaro.org>
Date: Wed, 20 Apr 2016 08:58:15 +0000
Subject: [PATCH 17/23] ia64: remove ARCH_WANT_OPTIONAL_GPIOLIB
Message-Id: <1461142701-21096-18-git-send-email-linus.walleij@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461142701-21096-1-git-send-email-linus.walleij@linaro.org>
In-Reply-To: <1461142701-21096-1-git-send-email-linus.walleij@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-gpio@vger.kernel.org, Alexandre Courbot <acourbot@nvidia.com>
Cc: Linus Walleij <linus.walleij@linaro.org>, =?UTF-8?q?Michael=20B=C3=BCsch?= <m@bues.ch>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

This symbols is not needed to get access to selecting the
GPIOLIB anymore: any arch can select GPIOLIB.

Cc: Michael B=C3=BCsch <m@bues.ch>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
Various arch maintainers:

either ACK this and I will merge it into the GPIO tree for v4.7
anticipating no clashes, or you wait until I have the enabling patch
upstream (patch 1 in this series, removing deps on
ARCH_[WANTS_OPTIONAL|REQUIRES]_GPIOLIB), and you will be able to
merge it to your arch trees yourselves for late v4.7
(post GPIO tree merge) or for v4.8.

You can also ask me for an immutable branch if you prefer that, I
will put the enabling patch on a branch and the patch for your arch
on top and ask you to pull it.

Select your option from the menu, silence probably means I will
merge it to the GPIO tree. Unless you are X86 or ARM in which case
I will be cautious.
---
 arch/ia64/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index b534ebab36ea..b97a4e08fae4 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -38,7 +38,6 @@ config IA64
 	select GENERIC_PENDING_IRQ if SMP
 	select GENERIC_IRQ_SHOW
 	select GENERIC_IRQ_LEGACY
-	select ARCH_WANT_OPTIONAL_GPIOLIB
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select GENERIC_IOMAP
 	select GENERIC_SMP_IDLE_THREAD
--=20
2.4.11

