From: "Jan Beulich" <jbeulich@novell.com>
Date: Tue, 05 May 2009 12:53:13 +0000
Subject: [PATCH] fix SAL info mutex handling
Message-Id: <4A0052D9.76EA.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Using up() on a mutex that wasn't necessarily acquired seems wrong.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 arch/ia64/kernel/salinfo.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.30-rc4/arch/ia64/kernel/salinfo.c	2009-04-30 09:42:36.000000000 +0200
+++ 2.6.30-rc4-ia64-salinfo-lock/arch/ia64/kernel/salinfo.c	2009-05-04 11:31:45.000000000 +0200
@@ -192,8 +192,8 @@ struct salinfo_platform_oemdata_parms {
 static void
 salinfo_work_to_do(struct salinfo_data *data)
 {
-	down_trylock(&data->mutex);
-	up(&data->mutex);
+	if (down_trylock(&data->mutex) = 0)
+		up(&data->mutex);
 }
 
 static void



