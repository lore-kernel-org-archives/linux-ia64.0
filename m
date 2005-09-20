From: Keith Owens <kaos@sgi.com>
Date: Tue, 20 Sep 2005 07:32:44 +0000
Subject: Announce: kdb v4.4 is available for kernel 2.6.14-rc1
Message-Id: <10726.1127201564@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12956.1085377697@kao2.melbourne.sgi.com>
In-Reply-To: <12956.1085377697@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a version of KDB that works reasonably well with the new
MCA/INIT model, in

ftp://oss.sgi.com/projects/kdb/download/v4.4/

  kdb-v4.4-2.6.14-rc1-common-1.bz2
  kdb-v4.4-2.6.14-rc1-i386-1.bz2
  kdb-v4.4-2.6.14-rc1-ia64-1.bz2

During MCA/INIT, the MCA/INIT handlers are the active tasks but you
almost always want to look at the task that was running when MCA/INIT
was delivered.  There is a new 'handlers' command on ia64, man
linux/Documentation/kdb/kdb.mm for details.

The register display (rd, r) and register modify (rm) commands still
need some work, in progress.  They always apply to the MCA/INIT
handlers, not the original task.  As a temporary workaround

  handlers hide (this is the default)
  set BTSP 1
  btc

Look for ia64_leave_kernel and copy the sp value immediately after that
line.  pt_regs <sp>+0x10 will give you the registers.
switch_stack <sp>-0x200 gives you the switch stack.

