From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 13 Feb 2006 17:34:33 +0000
Subject: [ANNOUNCE] salinfo 1.1 is available
Message-Id: <200602131034.33693.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith has put together salinfo 1.1, available here:

    ftp://kernel.org/pub/linux/kernel/people/helgaas/salinfo-1.1.tar.bz2

The changelog is:

       * mandir patch to Makefile, from SuSE.
       * gcc 4 alias fixes, from SuSE.
       * Remove spurious exports from /etc/sysconfig/salinfo_decode_all,
         from SuSE.
       * salinfo_decode_all has to catch signals so it can send them to its
         children.  SuSE's killproc sends three signals in quick succession,
         STOP, TERM, CONT which can cause a timing race where only the last
         one caught by salinfo_decode_all gets through to the children.  Do
         not catch SIGSTOP or SIGCONT, so killproc's SIGTERM gets through to
         the children.
       * Set some sensible defaults for MCA and INIT rate limiting.
       * Remove SGI specific decoding of nasid, now done in SGI's
         salinfo_decode_oem.
       * Detect and drop duplicate records.  This gives SAL the flexibility to
         save some records that would normally be lost over a reboot, without
         creating duplicate records in the filesystem.
       * Fix pointer signedness warnings from gcc 4.1.
       * Released as 1.1.
