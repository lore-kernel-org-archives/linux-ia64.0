From: Ville Herva <vherva@niksula.hut.fi>
Date: Fri, 07 Dec 2001 06:57:43 +0000
Subject: [Linux-ia64] hp i2000, ide-floppy driver does not see ls120 drive
Message-Id: <marc-linux-ia64-105590698805636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[I'd appreciate cc'ing me, I'm not on the list]

config:
2.4.16 + ia64-patch, HP i2000 dual itanic 800, ls120 super floppy drive.


The kernel does not see the ls120 drive (nothing in dmesg, no device
/dev/hd? nor /dev/fd0). Same deal with mandrake default kernel. 

Do you people have it working?

Do you know if lm_sensors or similar works or will work in future on
Itamium/i2000?

Other than that, everything works, sound, ntfs (it did give couple of
unaligned accesses), ext3, reiserfs... _Nice_ work, guys!

 
-- v --

v@iki.fi

