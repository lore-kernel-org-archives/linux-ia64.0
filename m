From: Matt_Domsch@Dell.com
Date: Mon, 30 Jul 2001 15:12:42 +0000
Subject: [Linux-ia64] efibootmgr 0.3.3-test4
Message-Id: <marc-linux-ia64-105590693005950@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

By request, here's another drop of efibootmgr.
http://domsch.com/linux/ia64/efibootmgr-0.3.3-test4.tar.gz.
I added a -w flag, which writes a per-system-unique signature to the MBR of
the MBR-partitioned disk you're creating the boot option for.  The signature
is just the st_rdev field from struct stat, but that will be
per-system-unique.  If you don't specify -w, and the disk signature is 0
(the default made by fdisk and friends), you'll get a nice ugly warning that
the EFI Boot Manager may not be able to detect what disk you're trying to
boot from.

As always, patches and feedback welcome.

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux
#2 Linux Server provider with 17% in the US and 14% Worldwide (IDC)!
#3 Unix provider with 18% in the US (Dataquest)!

