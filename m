From: Khalid Aziz <khalid_aziz@hp.com>
Date: Tue, 09 Jul 2002 15:53:44 +0000
Subject: [Linux-ia64] [PATCH] make xconfig broken in ia64-020622
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------2298D78BFDA8E4FDDA2C400D"
Message-Id: <marc-linux-ia64-105590701905745@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------2298D78BFDA8E4FDDA2C400D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

020622 version of ia64 patch breaks "make xconfig". This is due to a bug
in sound drivers configuration file. Attached patch fixes this problem.

--
Khalid 

====================================================================
Khalid Aziz                                   Linux Systems Division
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO
--------------2298D78BFDA8E4FDDA2C400D
Content-Type: text/plain; charset=us-ascii;
 name="patch.sound"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.sound"

--- linux-2.4.18-ia64-020622/drivers/sound/Config.in	Mon Jul  8 15:57:30 2002
+++ linux-2.4.18-ia64-020622-fixed/drivers/sound/Config.in	Mon Jul  8 15:58:43 2002
@@ -30,7 +30,7 @@
 	fi
     fi
 fi
-dep_tristate '  FM801' CONFIG_FM801 
+dep_tristate '  FM801' CONFIG_FM801 $CONFIG_SOUND $CONFIG_PCI
 dep_tristate '  Creative SBLive! (EMU10K1)' CONFIG_SOUND_EMU10K1 $CONFIG_SOUND $CONFIG_PCI
 dep_mbool    '    Creative SBLive! MIDI' CONFIG_MIDI_EMU10K1 $CONFIG_SOUND_EMU10K1 $CONFIG_EXPERIMENTAL
 dep_tristate '  Crystal SoundFusion (CS4280/461x)' CONFIG_SOUND_FUSION $CONFIG_SOUND

--------------2298D78BFDA8E4FDDA2C400D--


