From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 27 Aug 2002 00:30:41 +0000
Subject: [Linux-ia64] elilo 3.3 has been released!
Message-Id: <marc-linux-ia64-105590701905981@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have just released version 3.3 of elilo, the EFI bootloader 
for Linux/ia64 and Linux/ia32.

List of new features:
---------------------

  - The biggest change is that elilo is now fully compliant with the 
    EFI 1.10 specification in particular section 11.2.1.3: Directory Structures.
    This section describes where the bootloader should be placed in the EFI 
    system partition. Because this partition is OS neutral, no OS vendor is 
    supposed to leave bootloaders, config files on the root. Instead, the 
    specification dictates that the bootloader be placed in \EFI\FOO\elilo.efi 
    if FOO in the name of the OS distribution. It is IMPORTANT that every Linux
    distributor follow this rule.  To support such rule, elilo now only looks for 
    files in the directory it was loaded from, unless absolute paths are specified.
    (Thanks to Richard Hirst for contributing this feature)

  - Ability to load ELF/ia64 big-endian binaries (if using ELF p_paddr).

  - added -F fpswa_file option for IA64, to load a specific FPSWA driver

  - updated documentation

  - many bug fixes.

Change:
-------

  - Elilo will now look for the FPSWA driver on all accessible EFI system partitions.
    The driver name MUST be fpswa.efi and it MUST in a directory called 
    \EFI\Intel Firmware (no other directory is searched), as specified in the FPSWA 
    document (see http://developer/intel.com/design/itanium).  EFI ensures that only the 
    newest driver is actually loaded and activated.

Please look at Changelog for more details.


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

	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.3.tar.gz
	MD5SUM: aa240675ee8a57218dd2523a23fb5c4f

Enjoy,

-- 
-Stephane

