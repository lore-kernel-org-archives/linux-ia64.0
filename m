From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 02 Jul 2001 08:46:18 +0000
Subject: [Linux-ia64] gnu-efi-3.0/elilo-3.0 packages available
Message-Id: <marc-linux-ia64-105590693005807@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have uploaded the new version of the GNU-EFI package.
This version is the first one for which the libaries+include
files are separated from the bootloader (elilo).

As of this version:
	- gnu-efi-3.0.tar.gz: contains the efi library, header files,
                              and crt0s.
	- elilo-3.0.tar.gz  : contains the bootloader

Both packages are available from the HP Labs FTP site:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-3.0.tar.gz
	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.0.tar.gz

What's new ?
-----------
	gnu-efi-3.0:
		- split libraries and bootloader.
		- got rid of the W2U() macro, use -fshort-wchar instead.
		- better ia-32 support.

	elilo-3.0:
		- split libraries and bootloader.
		- ext2fs file access.
		- possibility to access files on any (recognized) device.
		- efi/ia32 loader (not fully tested, requires EFI >.36) (Mike Johnston).
		- rewritten wrapper code for gzip loader (Tony Luck).
		- completely rewritten filsystem interface (uses EFI protocol interface).
		- device naming scheme interface.
		- cleanup chooser interface.
		- machine-specific config file when netbooting (based on IP address)
		  (suggestion from Egan Ford).
		- architecture specific options support
		- possibility to specify a particular FPSWA driver file (IA-64 only)
		- many more cleanups and bug fixes (see ChangeLog)
		- more documentation (see all READMEs).
		- EDD3.0 is now forced
			
System Requirements:
--------------------
		- elilo-3.0 will boot any kernel >= 2.4.3
		- both elilo-3.0 and gnu-efi-3.0 require a GNU compiler with -fshort-wchar support (>= 2.96).
		- Stock 2.96 toolchain won't produce valid binaries without BFD specific patches.
		- for both architectures, it is recommended to use gcc-3.0 release which is known to 
		  generate valid binaries. Binary for elilo (elilo.efi) included in package.

		- EFI >= 12.33. Known issues with ext2fs (BlockIO access) and firmware Build103E. Build99, Build83
		  are known to work.

Enjoy,

-- 
-Stephane

