From: Keith Owens <kaos@sgi.com>
Date: Thu, 21 Jul 2005 01:24:59 +0000
Subject: kdb v4.4 supports OHCI keyboard in 2.6
Message-Id: <19923.1121909099@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kdb@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The 2.6.13-rc3 version of KDB (Linux Kernel Debugger) supports a USB
keyboard (CONFIG_KDB_USB).  At the moment it only supports the OHCI
interface, this is what SGI hardware uses.  If anybody has hardware
that uses the UHCI interface for the keyboard and can create a kdb
patch, that patch will be gratefully accepted.

ftp://oss.sgi.com/projects/kdb/download/v4.4/
ftp://ftp.ocs.com.au/pub/mirrors/oss.sgi.com/projects/kdb/download/v4.4/

