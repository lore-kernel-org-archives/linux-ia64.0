From: Bdale Garbee <bdale@gag.com>
Date: Fri, 10 Aug 2001 17:43:05 +0000
Subject: [Linux-ia64] Debian GNU/Linux for IA-64
Message-Id: <marc-linux-ia64-105590698805058@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It is my pleasure to announce that Debian has accepted IA-64 as a supported 
architecture for the upcoming Debian GNU/Linux 3.0 (woody) stable release.

Information about Debian is available on the web at www.debian.org.

In celebration of this milestone, and to make it easier for others in the 
IA-64 community to use and help us improve Debian before woody releases, we 
have created an installer CD image that is now available for download.  This 
CD image contains the Debian installation toolset and all of the essential
packages required to install Debian on Itanium systems.  Additional 
packages may then be installed over the network from Debian's mirrors 
quite easily.

The IA-64 installer CD image is now available by either HTTP or FTP from 
these locations:

	http://gluck.debian.org/ia64/cd-20010810.iso.gz
	ftp://gluck.debian.org/ia64/cd-20010810.iso.gz

This image has been tested on production HP i2000 and prototype BigSur
systems.  It should work on Lion systems and Itanium systems from other 
vendors as well, and we welcome reports of any problems experienced on other
Itanium systems.  Please read the README.txt file in the root of the CD for
a few platform-specific installation instructions... a copy of which is 
appended to this message.

Questions or feedback should be directed to the debian-ia64 mailing list.
Archives and subscription information for this list may be found via the
link on the Debian ia64 port page at:

	http://www.debian.org/ports/ia64/

The release of this installer CD image and the acceptance of IA-64 for 
release with Debian 3.0 would not have happened without significant
contributions from Randolph Chung, HP's Linux Systems Operation, Richard
Hirst at Linuxcare, Progeny Linux Systems, and the many Debian package
maintainers whose packages are now available for IA-64.  My thanks to all
of them!

Bdale

     - - - - - - - - - -     README.txt     - - - - - - - - - -

                 Debian GNU/Linux ia64 base install CD

        DEVELOPMENT SOFTWARE, UNTESTED, YOU HAVE BEEN WARNED!!!!!!

Instructions:

Get to an EFI shell prompt, which might mean renaming your
/boot/efi/startup.nsh file.

Figure out which of fs0, fs1, fs2, etc is your CDROM; fs3 in this example.

Enter  "fs3:<cr>", should have an fs3: prompt.

Enter  "install<cr>", and away you go!

This CD is based on unstable packages, as not everything needed was included
in testing when the ISO was created.

The install follows the standard Debian proceedure, with the following
exceptions:

1. When given the choice, install 'sid' and not 'woody'.

2. Do not try to create a boot floppy, as that step does not work.  You
   can boot from this CD later, if you need to recover your system; just
   boot it as described above and then use Alt-F2 to get to a shell
   prompt.

3. In the second stage install, when configuring APT, select some suitable
   http or ftp mirror.  Do not select the CD as a source, as this CD
   contains only the base system packages.

When the install is complete, you should find a new EFI Boot Manager menu
entry "Debian GNU/Linux", which the system should now boot as default.

Richard Hirst  <rhirst@linuxcare.com>

