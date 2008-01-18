From: Matt Domsch <Matt_Domsch@dell.com>
Date: Fri, 18 Jan 2008 20:24:20 +0000
Subject: [ANNOUNCE] efibootmgr v0.5.4
Message-Id: <20080118202420.GD29435@auslistsprd01.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

efibootmgr v0.5.4 is released now.  This is a minor update to 0.5.3
that most distributions have, cleanups and incorporating a few patches
that the distros were carrying (Debian, Fedora, openSUSE shouldn't
have any pending patches in their packages anymore, if you do please
send them to me).

Note, in Fedora rawhide, and what I plan for RHEL 6, efibootmgr is no
longer included in the elilo package, but is split into its own RPM.
This enables the replacement of elilo with a UEFI-aware grub boot
loader instead.

Note: there is now a GIT tree available.

http://linux.dell.com/efibootmgr/permalink/efibootmgr-0.5.4.tar.gz
http://linux.dell.com/efibootmgr/permalink/efibootmgr-0.5.4.tar.gz.sign
git clone http://linux.dell.com/git/efibootmgr.git/


Changelog since 0.5.3:

Doug Chapman (1):
      patch to make efibootmgr have non-zero exit code on errors

Matt Domsch (11):
      apply patch from Dave Jiang <djiang@mvista.com> to enable
      cross-building
      add -lz to libs, needed when libpci happens to need it
      cleanup exit values a little
      cleanup a few unaligned access warnings
      avoid more unaligned access warnings
      make sure GPT_HEADER_SIGNATURE is a 64-bit value
      src/lib/efi.c: include linux/types.h
      Makefile cleanups
      RPM spec rewrite for Fedora inclusion
      replacing elilo < 3.6-6, not -5
      update ChangeLog


Thanks,
Matt

-- 
Matt Domsch
Linux Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
