From: Bill Nottingham <notting@redhat.com>
Date: Wed, 21 Jun 2000 17:44:53 +0000
Subject: [Linux-ia64] new Red Hat Linux for IA-64 available
Message-Id: <marc-linux-ia64-105590678205167@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new Red Hat Linux Development Release for IA-64 is available.
You can download this release from:

	ftp://ftp.redhat.com/pub/redhat/ia64/
	
ISO images for both the source and binary CD are available.
See the README in that directory for specific installation instructions.

There is a mailing list to discuss the Red Hat Linux IA-64 release,
and Linux on the IA-64 in general. To subscribe, send mail to
ia64-list-request@redhat.com with

subscribe

in the subject line. You can leave the body empty.

Changes from the previous release:

- X server support is now included. Only the Rage128 driver is
  tested; other drivers may work. Run 'Xconfigurator' after the
  install to set up X, and do *not* choose to test the setup.
  If all else fails, edit /etc/X11/XF86Config-4.
- The kernel has been updated to 2.4.0-test1; this kernel includes
  some preliminary module support.
- ia32 binary emulation support is included. Binaries from Red Hat
  Linux 6.2 should run OK (netscape is included.)
- GNOME 1.2 is included

Compatibility Notes:

Programs from the previous (May) Red Hat Linux IA-64 Development Release
should run on this release; compatibility is not guaranteed, though.

However, programs built on both this and the May release
will not run on future releases. Similarly, programs built
on future releases will not run on this release.

Bill


