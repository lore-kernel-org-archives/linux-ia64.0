From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 06 Aug 2003 01:34:46 +0000
Subject: PATCH: Use rm -f instead of rm
Message-Id: <marc-linux-ia64-106013374422175@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"rm" may be aliased to "rm -i".

# make

may prompt for user response. It kills "nohup make".


H.J.
--- linux/arch/ia64/Makefile.ia64	Tue Aug  5 17:21:30 2003
+++ linux/arch/ia64/Makefile	Tue Aug  5 18:30:27 2003
@@ -28,7 +28,7 @@ CHECK_GAS_FOR_HINT=arch/ia64/scripts/che
 MAKE_GAS_HINT_TEST=arch/ia64/scripts/make_gas_hint_test
 
 ifneq (, $(shell ls $(CHECK_GAS_FOR_HINT)))
-$(shell rm $(CHECK_GAS_FOR_HINT))
+$(shell rm -f $(CHECK_GAS_FOR_HINT))
 endif
 
 CHECK_GAS_CMD:=($(CC) $(MAKE_GAS_HINT_TEST).c -o $(MAKE_GAS_HINT_TEST) |$(AS) -o $(CHECK_GAS_FOR_HINT) -;rm $(MAKE_GAS_HINT_TEST))>&/dev/null
