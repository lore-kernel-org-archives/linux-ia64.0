From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 19 Mar 2002 15:53:37 +0000
Subject: [Linux-ia64] qla1280 v3.23.15
Message-Id: <marc-linux-ia64-105590701905303@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I just uploaded the latest version of the qla1280 driver to
http://www.wildopensource.com/~jes/linux/qla-3.23.15.tar.gz

This time I put out a tarball instead of a .diff since it will make it
easier to try it out against other kernels versions than the one I am
running.

This release has quite a few changes since the .13 release. A lot of it
is still cleanups, but I am getting to the point where I can start
fixing the actual code. In particular I am now enabling interrupts very
early on in order to be able to clean up the mailbox handling code
(which currently runs the interrupt handler itself).

Please report success/failure to me directly or to this list.

NOTE: This is an interim release meant for testing only, do not use this
in production unless you're willing to take the risk.

Thanks,
Jes

