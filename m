From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 06 Mar 2002 22:33:15 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905235@msgid-missing>
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

Peter> With this patched kernel, one cannot configure the loop device
Peter> when using the HP simulator.

Peter> I moved the line that sourced the block-device config script
Peter> outside the HP_SIM guards, as in the appended patch.

David> Hmmh, I'm a bit reluctant to do this, as it will pull in all
David> the other drivers, 99% of which won't build.  How about just
David> including the loopback prompt directly in the ia64 config?  If
David> this works, send me a patch and I'll include it.  (Yes, I
David> realize that's kludgy, but presumably this will all get cleaned
David> up if and when the new kernel configuration makes it into 2.5).


OK, Here it is.  We probably need to do something similar for the scsi
config.  This patch is against a 2.4.18 kernel with the IA64 patch.

--- linux/arch/ia64/config.in	Thu Mar  7 09:21:50 2002
+++ linux-local/arch/ia64/config.in	Thu Mar  7 09:28:08 2002
@@ -152,6 +152,17 @@
 fi
 endmenu
 
+else # ! HP_SIM
+mainmenu_option next_comment
+comment 'Block devices'
+tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
+dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD $CONFIG_NET
+
+tristate 'RAM disk support' CONFIG_BLK_DEV_RAM
+if [ "$CONFIG_BLK_DEV_RAM" = "y" -o "$CONFIG_BLK_DEV_RAM" = "m" ]; then
+   int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
+fi
+endmenu
 fi # !HP_SIM
 
 mainmenu_option next_comment


