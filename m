From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 14 Mar 2005 23:43:19 +0000
Subject: kernel update (relative to 2.4.29)
Message-Id: <1110843799.4088.38.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 kernel patch for Linux 2.4.29 is available here:

  ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.29-ia64-050312.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Bjorn

IA64-related changes since 2.4.26:
  * Perfmon:
    - use seq_file for /proc to avoid buffer overflows (Stephane Eranian, Dean Nelson).
    - fix /proc/pal/CPU*/bus_info descriptions (Stephane Eranian).
    - fix perfmon "BEER promotion" typo (Stephane Eranian).
    - clear sampling buffer at init (Stephane Eranian).
  * Misc bug-fixes:
    - allow IO port space without EFI RT attribute (Bjorn Helgaas).
    - fix FPH state check to keep task from seeing another task's regs (Arun Sharma).
    - fix pte_modify bug that allowed mprotect() to change too many bits (David Mosberger).
    - add unw_unwind_to_user() sanity check (Keith Owens).
    - add missing syscall slot.
    - fix ptrace corner cases (Yanmin Zhang).

N.B.  While testing this patch, I noticed that the ptrace fixes caused
anything linked with the profiling libc in Debian to fail.  The same
thing happens with the current 2.6 kernel, so I think the problem is
most likely in the Debian profiling libc.



