From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 21 Aug 2003 21:27:46 +0000
Subject: elilo-3.4 is now available
Message-Id: <marc-linux-ia64-106150146601650@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have just released version 3.4 of elilo, the EFI bootloader 
for Linux/ia64 and Linux/ia32.

This new release incorporates a few new features and some important
bug fixes. Here is a short summary:

	- When netbooting, elilo-3.4 now only looks files in the
	  directory it was downloaded from on the TFTP server. This allows
	  a sysadmin to clearly encapsulate a machine configuration into a
	  particular subdirectory. Of course, if you specify an absolute path, 
	  files can be placed anywhere within the TFTP directory structure. 
	  This MAY BREAK SOME SETUPS but is a much cleaner design. An explicit 
	  error message is printed warning the user when the config file is not
	  found. This new feature aligns the netbooting and local disk booting 
	  behaviors and facilitates setup on large cluster environments.

	- The simple chooser has some new commands to view the current state
	  (Press ? for details).

	- I have increased the default buffer size for downloaded file to 
	  16MB from 4MB. This should make it faster when downloading large
	  files.

	- The ext2 filesystem support is still present but not compiled
	  in by default to prevent errors when using it on an ext3fs 
	  partition. The ext2 code does not understand the journal.

	- Updates to elilo for IA-32/EFI based platforms (for machines
	  using EFI boot floppies on top of legacy BIOS). The loader 
	  can load unmodified Linux kernel/initrd image from either the
	  local disk or via netbooting. Thanks to Matt Tolentino at Intel
	  for these updates.

	- Updated documentation. Make sure you look at docs/netbooting.txt
	  for examples.

Some of the bugs fixed include:

	- downloading of large files with EFI 14.60 or higher now works.
	  Thanks to Egan Ford and Guy Laborde for reporting the bug and 
	  providing a fix.
	  
	- some file paths related problems when booting from the local disk.

Make sure you look at the README file for instructions on how to compile
this package on both IA-64 and IA-32.

As usual, I have included precompiled binaries for IA-64 (elilo-ia64.efi)
and IA-32 (elilo-ia32.efi). To try out the IA-32 version, you need a PC
with EFI support. This can either be a native EFI implementation or
a PC with a legacy BIOS booted with the EFI floppies from the Intel
sample implementation which you can get at:

	http://developer.intel.com/technology/efi

The new version of elilo can be downloaded from:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.4.tar.gz
	MD5SUM: 52b2ea392e86df747c46b9200319e3f9

Thanks to the people who have reported bug, submitted patches and updates.
A special thank to Matt Tolentino for providing the IA-32 updates on time.

-- 
-Stephane
