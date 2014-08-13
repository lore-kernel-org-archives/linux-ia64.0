From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed, 13 Aug 2014 10:28:52 +0000
Subject: [PATCH v4 2/8] serial: sunzilog: Remove unnecessary volatile keyword
Message-Id: <1407925738-26170-3-git-send-email-thierry.reding@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
In-Reply-To: <1407925738-26170-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Boyd <sboyd@codeaurora.org>, Sam Ravnborg <sam@ravnborg.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, linux-serial@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

The field annotated with volatile are all accessed through I/O accessors
so they don't need to be explicitly marked. The accessors will take care
of it.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Changes in v4:
- new patch

 drivers/tty/serial/sunzilog.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/tty/serial/sunzilog.h b/drivers/tty/serial/sunzilog.h
index 5dec7b47cc38..de2850c1ab57 100644
--- a/drivers/tty/serial/sunzilog.h
+++ b/drivers/tty/serial/sunzilog.h
@@ -2,10 +2,10 @@
 #define _SUNZILOG_H
 
 struct zilog_channel {
-	volatile unsigned char control;
-	volatile unsigned char __pad1;
-	volatile unsigned char data;
-	volatile unsigned char __pad2;
+	unsigned char control;
+	unsigned char __pad1;
+	unsigned char data;
+	unsigned char __pad2;
 };
 
 struct zilog_layout {
-- 
2.0.4

