From: Jason P Holland <jholland@cs.selu.edu>
Date: Wed, 30 Oct 2002 16:18:50 +0000
Subject: [Linux-ia64] PXE boot off HP zx6000
Message-Id: <marc-linux-ia64-105590709805294@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hello,
  i'm trying to do a PXE boot from an HP zx6000 workstation.  My tftp 
server is version 0.29-3 for Redhat ia4.  I'm also using dhcp 3.0p11-9.  I 
get the following error from the EFI shell trying to do a lanboot

PXE-E05:  Download buffer is smaller than the requested file
Exit status code: Invalid Parameter

i've seen a few messages about this in the archives, but nothing i tried
has worked.  the file i want to boot off of is pxelinux.0 from the
syslinux package.  its only 10820 bytes, is the buffer really too small or
is there another problem i'm just not seeing?  if i need to post some
config files, please let me know.  thanks

jason


