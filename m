From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 06 Jan 2004 21:29:54 +0000
Subject: kernel update (relative to 2.4.24)
Message-Id: <200307021108.36683.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 kernel patch for Linux 2.4.24 is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.24-ia64-040106.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Bjorn


There were no ia64-specific changes between 2.4.23-ia64-031205
and 2.4.24-ia64-040106.  Summary of changes from 2.4.23 to 2.4.24
(from Marcelo's announcement):

<bjorn.helgaas:hp.com>:
  o Fix 2.4 EFI RTC oops

<marcelo.tosatti:cyclades.com>:
  o Andrea Arcangeli: malicious users of mremap() syscall can gain priviledges

<marcelo:logos.cnet>:
  o Harald Welte: Fix ipchains MASQUERADE oops
  o Change EXTRAVERSION to 2.4.24-rc1

<trini:mvista.com>:
  o /dev/rtc can leak parts of kernel memory to unpriviledged users

Jean Tourrilhes:
  o IrDA kernel log buster


