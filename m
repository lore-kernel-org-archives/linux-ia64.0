From: Uros Prestor <uros@turbolinux.com>
Date: Fri, 03 Nov 2000 02:48:27 +0000
Subject: [Linux-ia64] NFS problems with 2.4.0-test10
Message-Id: <marc-linux-ia64-105590678205648@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anybody observed NFS problems with the latest kernel?  I have
installed 2.4.0-test10 + 1101 patch on a 4xB1 Lion; I can reliably crash
a system by copying a large file over the NFS.  I have no problems with
the same kernel on a 2xB2 BigSur.  Kernel was compiled with all the
B-stepping workarounds enabled and none for the A-steppings.

Uros

--
Uros Prestor
uros@turbolinux.com




