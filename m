From: "Li, Shuo" <shuo.li@intel.com>
Date: Mon, 25 Jun 2001 23:47:28 +0000
Subject: [Linux-ia64] Red Hat Installer cannot find the hard drive
Message-Id: <marc-linux-ia64-105590693005762@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Does anybody know what caused the following problem and how to fix it?

The problem happens at Linux install time. After the installer come back
after trying to detect the hard drive, it reports an error saying

Partiition(s)) do not end on cylinder boundary:

This occurs because the drive geometry detected by kernel used by the
installer is different than the drive geometry used when the drive was
partitioned. This can be corrected by specifying the drive geometry on the
kernel command line when booting the installer.

Shuo 



