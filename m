From: "Akhter, Shameem F" <shameem.f.akhter@intel.com>
Date: Thu, 22 Jun 2000 04:01:51 +0000
Subject: RE: [Linux-ia64] new Red Hat Linux for IA-64 available
Message-Id: <marc-linux-ia64-105590678205169@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205167@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205167@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am having problem with the "redhat" ftp site, whereas "cygnus" ftp is
working fine. Any idea?

Thanks.

-- Shameem

Shameem Akhter

IACG
IA64 Tools Engineering
Ph: (503) 264-1644



-----Original Message-----
From: Bill Nottingham [mailto:notting@redhat.com]
Sent: Wednesday, June 21, 2000 10:45 AM
To: linux-ia64@linuxia64.org
Cc: ia64-tools@napali.hpl.hp.com
Subject: [Linux-ia64] new Red Hat Linux for IA-64 available


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


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64



