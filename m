From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 28 Feb 2002 04:40:53 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905196@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:

David> The latest ia64 patch is now availabe at ftp.CC.kernel.org in
David> /pub/linux/kernel/ports/ia64/v2.4/:

With this patched kernel, one cannot configure the loop device when
using the HP simulator.

I moved the line that sourced the block-device config script outside
the HP_SIM guards, as in the appended patch.

--- /usr/src/linux-2.4.18/arch/ia64/config.in	Sat Nov 10 09:26:17 2001
+++ arch/ia64/config.in	Thu Feb 28 15:11:51 2002
@@ -134,7 +134,7 @@
 
 source drivers/mtd/Config.in
 source drivers/pnp/Config.in
-source drivers/block/Config.in
 source drivers/message/i2o/Config.in
 source drivers/md/Config.in
 
@@ -152,6 +152,7 @@
 endmenu
 
 fi # !HP_SIM
+source drivers/block/Config.in
 
 mainmenu_option next_comment
 comment 'SCSI support'



