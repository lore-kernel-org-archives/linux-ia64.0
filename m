From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 15 Oct 2002 18:01:07 +0000
Subject: [Linux-ia64] elilo-3.3a is now available
Message-Id: <marc-linux-ia64-105590709805163@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have just released version 3.3a of elilo, the EFI bootloader 
for Linux/ia64 and Linux/ia32.

Typically elilo is on a 6-month revision cycle but I have decided to release
an updated version to fix some important bugs found in the last two months. 

This version DOES NOT have any new features simply bug fixes.
I *STRONGLY* recommend that everyone migrates to this new version as 
several important bugs have been fixed. See ChangeLog for details.

I would like to thanks Levent Akyl, NOMURA Jun'ichi, and Andreas Schwab
for submitting bug reports and patches for this release.

To compile this package on both IA-32 and IA-64, you need gcc3.x and
binutils 2.11.90 or higher. Also if you're using anything newer than 
gcc3.0 release, you need to grab the updated version of the gnu-efi
package, i.e., gnu-efi-3.0a, because there were some changes in the
way gcc treats constant strings which impact the loader script used
to build elilo. You can grab the package at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-3.0a.tar.gz

As usual, I have included precompiled binaries for IA-64 (elilo-ia64.efi)
and IA-32 (elilo-ia32.efi). To try out the IA-32 version, you need a PC
with EFI support. This can either be a native EFI implementation or
a PC with a legacy BIOS booted with the EFI floppies from the Intel
sample implementation which you can get at:

	http://developer.intel.com/technology/efi

The new version of elilo can be downloaded from:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.3a.tar.gz
	MD5SUM: de5c507c9abbd24c993ac280835dcc57

Enjoy,

-- 
-Stephane

