From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 09 Jan 2004 17:38:18 +0000
Subject: kernel update (relative to 2.4.24)
Message-Id: <200401091038.18870.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200307021108.36683.bjorn.helgaas@hp.com>
In-Reply-To: <200307021108.36683.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just put a new 2.4.24 ia64 patch on kernel.org:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.24-ia64-040109.diff.gz

The only difference from the 040106 patch is a change to work around
an apparent menuconfig bug (when you select "HP", to build an HP-zx1
flavor kernel, menuconfig silently selected "HP-simulator" instead,
which builds a kernel for the Ski simulator).  This was a problem in
the 2.4.23-ia64-031205 patch as well.

Bjorn

