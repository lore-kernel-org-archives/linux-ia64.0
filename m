From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 11 May 2004 18:28:42 +0000
Subject: kernel update (relative to 2.4.26)
Message-Id: <200405111228.42219.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 kernel patch for Linux 2.4.26 is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.26-ia64-040510.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Bjorn

Changes since 2.4.25:
  * MCA/INIT/CMC/CPE:
    - copy records so we don't miss them when they happen too fast (Keith Owens).
  * IA32 emulation:
    - sys32_rt_sigtimedwait() fix (Arun Sharma).
    - make ia32 core dumps work (Arun Sharma).
  * Misc bug-fixes:
    - unwind update (Keith Owens).
    - fix unwind off-by-on error for FP regs (David Mosberger).
    - fix NULL-pointer dereference in unwinder (David Mosberger).
    - fix NULL-pointer dereference in hugetlb mmap failure path (Jack Steiner).
    - important fix for NaT corruption in signal path (David Mosberger).
      (see http://www.gelato.unsw.edu.au/linux-ia64/0402/8515.html)
    - use __builtin_trap() in BUG (Jason Uhlenkott, David Mosberger)
