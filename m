From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 25 Dec 2014 09:28:55 +0000
Subject: [PATCH repost 07/16] ia64/uaccess: fix sparse errors
Message-Id: <1419499661-8566-8-git-send-email-mst@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1419499661-8566-1-git-send-email-mst@redhat.com>
In-Reply-To: <1419499661-8566-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thierry Reding <treding@nvidia.com>, linux-ia64@vger.kernel.org

virtio wants to read bitwise types from userspace using get_user.  At the
moment this triggers sparse errors, since the value is passed through an
integer.

Fix that up using __force.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 arch/ia64/include/asm/uaccess.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index 103bedc..a540705 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -197,7 +197,7 @@ extern void __get_user_unknown (void);
 		      case 8: __get_user_size(__gu_val, __gu_ptr, 8, __gu_err); break;	\
 		      default: __get_user_unknown(); break;				\
 		}									\
-	(x) = (__typeof__(*(__gu_ptr))) __gu_val;					\
+	(x) = (__force __typeof__(*(__gu_ptr))) __gu_val;					\
 	__gu_err;									\
 })
 
-- 
MST

