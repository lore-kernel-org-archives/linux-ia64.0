From: Khalid Aziz <khalid@fc.hp.com>
Date: Wed, 10 Jul 2002 17:05:19 +0000
Subject: Re: [Linux-ia64] [PATCH] make xconfig broken in ia64-020622
Message-Id: <marc-linux-ia64-105590701905758@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Absolutely. xconfig parser has major problems with the following patch
to arch/ia64/config.in in 020622:

+else # ! HP_SIM
+mainmenu_option next_comment
+comment 'Block devices'
+tristate 'Loopback device support' CONFIG_BLK_DEV_LOOP
+dep_tristate 'Network block device support' CONFIG_BLK_DEV_NBD
$CONFIG_NET
+
+tristate 'RAM disk support' CONFIG_BLK_DEV_RAM
+if [ "$CONFIG_BLK_DEV_RAM" = "y" -o "$CONFIG_BLK_DEV_RAM" = "m" ]; then
+   int '  Default RAM disk size' CONFIG_BLK_DEV_RAM_SIZE 4096
+fi
+endmenu

xconfig parser looks at this definition of 'Block devices' and the one
in drivers/block/Config.in and considers them duplicates inspite of the
conditional. With this patch, you can not configure loopback device or
RAM disk unless you are configuring for HP Simulator.

Without the patch I sent, "make xconfig" won't even start. So this patch
only makes xconfig atleast partially usable.

--
Khalid

Xavier Bru wrote:
> 
> Unfortunatly, there are more things broken with make xconfig:
> 
> . multiple conditions are not handled by tkparse:
> 
> eg: unable to set CONFIG_IA64_MCA when CONFIG_IA64_DIG is set.
> 
> if [ "$CONFIG_IA64_GENERIC" = "y" ] || [ "$CONFIG_IA64_DIG" = "y" ] \
>    || [ "$CONFIG_IA64_HP_ZX1" = "y" ]; then
>         bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
>         define_bool CONFIG_PM y
> fi
> 
> . block device options are not generated in 2.4.18:
> 
> ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_LOOP).
> ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_NBD).
> ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_RAM).
> Having a look in tkparse.c, we can read:
> " * TO DO:
>  * - xconfig is at the end of its life cycle.  Contact <mec@shout.net> if
>  *   you are interested in working on the replacement."
> 
> I think that the linux hackers probably use make menuconfig, as they
> did not report such problems :-) ???
> Xavier
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

==================================
Khalid Aziz                                   Linux Systems Division
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO

