From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Wed, 10 Jul 2002 16:06:03 +0000
Subject: RE: [Linux-ia64] [PATCH] make xconfig broken in ia64-020622
Message-Id: <marc-linux-ia64-105590701905757@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Unfortunatly, there are more things broken with make xconfig:

. multiple conditions are not handled by tkparse:

eg: unable to set CONFIG_IA64_MCA when CONFIG_IA64_DIG is set.

if [ "$CONFIG_IA64_GENERIC" = "y" ] || [ "$CONFIG_IA64_DIG" = "y" ] \
   || [ "$CONFIG_IA64_HP_ZX1" = "y" ]; then
	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
	define_bool CONFIG_PM y
fi

. block device options are not generated in 2.4.18:

ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_LOOP).
ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_NBD).
ERROR - Attempting to write value for unconfigured variable (CONFIG_BLK_DEV_RAM).
Having a look in tkparse.c, we can read:
" * TO DO:
 * - xconfig is at the end of its life cycle.  Contact <mec@shout.net> if
 *   you are interested in working on the replacement."

I think that the linux hackers probably use make menuconfig, as they
did not report such problems :-) ???
Xavier

