From: "Akhter, Shameem F" <shameem.f.akhter@intel.com>
Date: Tue, 26 Jun 2001 00:00:36 +0000
Subject: RE: [Linux-ia64] Red Hat Installer cannot find the hard drive
Message-Id: <marc-linux-ia64-105590693005763@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005762@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005762@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I got the same problem. You can try to do the low-level format for the
harddrive and rest, go through the installation process. That should resolve
the error. At least it worked for me.

Regards,

-- Shameem

Shameem Akhter
Platform & Technology Enabling
Solution Enabling Group
Telephone: (503) 264-1644 (O)
           (503) 970-3112 (C)

If you would like to join "Intel Software Community" (ISC), please visit
http://msllinux.dp.intel.com/mailman/listinfo/isc


-----Original Message-----
From: Li, Shuo [mailto:shuo.li@intel.com]
Sent: Monday, June 25, 2001 4:47 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Red Hat Installer cannot find the hard drive


Does anybody know what caused the following problem and how to fix it?

The problem happens at Linux install time. After the installer come back
after trying to detect the hard drive, it reports an error saying

Partiition(s)) do not end on cylinder boundary:

This occurs because the drive geometry detected by kernel used by the
installer is different than the drive geometry used when the drive was
partitioned. This can be corrected by specifying the drive geometry on the
kernel command line when booting the installer.

Shuo 



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


