From: Matt_Domsch@Dell.com
Date: Tue, 22 Oct 2002 21:32:02 +0000
Subject: [Linux-ia64] efibootmgr v0.4.1
Message-Id: <marc-linux-ia64-105590709805206@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's efibootmgr 0.4.1 - aka the Dann Frazier release.

Changes:
* Tue Oct 22 2002 Matt Domsch <Matt_Domsch@dell.com>
- ran docbook2man on the man page Dann Frazier created
- Added man page to spec file
- Added patches from Dann Frazier
  - Removes the requirement to be root to run efibootmgr.  This lets
    mortal users run efibootmgr to check the version, and see the
    --help output. It should also allow efibootmgr to work under
    security systems without the strict root/non-root dichotomy.
    - Checks to see if a boot option was specified when a boot option
    deletion was requested.
- Released version 0.4.1

* Sun Jul 21 2002 Matt Domsch <Matt_Domsch@dell.com>
- Added kernel_has_blkgetsize64() test, now uses BLKGETSIZE64 if on a
  known-good kernel.  This is important when the Large Block Device (64-bit
  block address) patch gets merged into the 2.5 kernel. (as it is now!)


http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.1.tar.gz
http://domsch.com/linux/ia64/efibootmgr/efibootmgr-0.4.1.tar.gz.sign

Thanks to Dann for providing all the reasons for doing this release.
-Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com



