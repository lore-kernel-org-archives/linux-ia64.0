From: Keith Owens <kaos@sgi.com>
Date: Sat, 19 Oct 2002 01:22:06 +0000
Subject: [Linux-ia64] Planned removal of USB keyboard support from kdb
Message-Id: <marc-linux-ia64-105590709805198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sebastien Lelarge did a patch for USB keyboard support in kdb, to
support IA64 machines made by Bull.  AFAICT nobody has managed to get
this code to work, including the USB maintainer.  The USB code in kdb
for 2.5 kernels is a straight copy of the 2.4 code and will not even
compile, I have asked for updates to make it work on 2.5 with no
response.

Has anybody got USB keyboard support to work on 2.4 kernels?

If it works on 2.4, will anybody make USB support work in kdb for 2.5
kernels?  i386 only will do, kdb for ia64 is waiting for a current ia64
2.5 patch from David Mosberger (away at the moment).

Without evidence that this feature works and support for 2.5 kernels,
USB keyboard support will be removed from kdb.  I will wait until
November 12 before deciding.


