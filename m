From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 16 Jan 2002 20:37:54 +0000
Subject: [Linux-ia64] PXE booting, one last question
Message-Id: <marc-linux-ia64-105590698805860@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Does anyone have a sample elilo.conf file for booting the kernel and
then mounting an initial ramdisk?  I have an elilo.conf that works for
loading and mounting a ramdisk from an LS-120, but it can't mount the
ramdisk when booting via the network.  I checked my tftpd log, and the
initial ramdisk is getting transferred to the client.

Mike

