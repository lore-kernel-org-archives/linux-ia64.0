From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 03 Feb 2005 22:12:19 +0000
Subject: PATCH: 2.4/2.6: Remove duplicated END(memcpy)
Message-Id: <20050203221219.GA28919@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The new assembler doesn't like

	.proc memcpy
	.endp memcpy
	.proc __copy_user
	.endp memcpy
	.endp __copy_user


H.J.
----
--- linux-2.4.21/arch/ia64/lib/memcpy_mck.S.endp	2005-02-03 12:20:36.000000000 -0800
+++ linux-2.4.21/arch/ia64/lib/memcpy_mck.S	2005-02-03 13:49:51.000000000 -0800
@@ -541,7 +541,6 @@ EK(.ex_handler,  (p17)	st8	[dst1]=r39,8)
 #undef B
 #undef C
 #undef D
-END(memcpy)
 
 /*
  * Due to lack of local tag support in gcc 2.x assembler, it is not clear which
