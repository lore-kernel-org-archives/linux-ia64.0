From: John Kohl <jtk@rational.com>
Date: Thu, 01 Mar 2001 14:44:02 +0000
Subject: [Linux-ia64] arch/ia64/config.in syntax error (2001-02-28 patch)
Message-Id: <marc-linux-ia64-105590693005228@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes a syntax error (bad line break) in arch/ia64/config.in
(so that PTCG gets set properly):

--- config.in~	Thu Mar  1 09:32:43 2001
+++ arch/ia64/config.in	Thu Mar  1 09:41:05 2001
@@ -57,8 +57,7 @@
 	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" = "y" ]; then
 	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIFIC
 	fi
-	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B0_SPECIFIC" = "y"
-	     -o "$CONFIG_ITANIUM_B1_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B2_SPECIFIC" = "y" ]; then
+	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B0_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B1_SPECIFIC" = "y" -o "$CONFIG_ITANIUM_B2_SPECIFIC" = "y" ]; then
 	  define_bool CONFIG_ITANIUM_PTCG n
 	else
 	  define_bool CONFIG_ITANIUM_PTCG y

-- 
=John Kohl <jtk@rational.com>, Senior Staff Software Engineer
Rational Software, Configuration Management Business Unit
Mark your calendars!  Rational User Conference 2001, July 22-26, 2001
in beautiful Denver, Colorado

