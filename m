From: Eric Piel <Eric.Piel@lifl.fr>
Date: Wed, 09 Mar 2005 15:12:06 +0000
Subject: [PATCH] Documentation update about pal_halt_light
Message-Id: <422F1246.80008@lifl.fr>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010807010409020009070409"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010807010409020009070409
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

I had to hang around in the code to find this invaluable option 
"nohalt". Let's document it!

That's a trivial documentation update, please apply.

Eric Piel

--
Documentation update about pal_halt_light on IA-64

Signed-off-by: Eric Piel <eric.piel@lifl.fr>
--

--------------010807010409020009070409
Content-Type: text/x-patch;
 name="parameter-nohalt-ia64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="parameter-nohalt-ia64.patch"

--- kernel-parameters.txt.bak	2005-03-09 15:39:10.348323818 +0100
+++ kernel-parameters.txt	2005-03-09 15:55:19.583141065 +0100
@@ -837,6 +837,9 @@
 			instruction doesn't work correctly and not to
 			use it.
 
+	nohalt		[IA-64] Tells the kernel not to use the power saving 
+			function PAL_HALT_LIGHT when idle.
+
 	noirqdebug	[IA-32] Disables the code which attempts to detect and
 			disable unhandled interrupt sources.
 

--------------010807010409020009070409--
