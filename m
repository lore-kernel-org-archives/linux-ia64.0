From: chas williams <chas@cmf.nrl.navy.mil>
Date: Wed, 14 Aug 2002 13:31:45 +0000
Subject: [Linux-ia64] patching the syscall table via a module
Message-Id: <marc-linux-ia64-105590701905938@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

afs patches the syscall table when it loads as a module.  currently afs
pags and pioctl are implemented this way.  while this might change in
the future, its not going to happen any time soon.  i have run into a
problem with this recently, and noticed that sys_call_table is declared
as .rodata.  my older ia64 machines dont seem to enforce the read only,
but the new sn machine does!

is there a particular reason the sys_call_table needs to be .rodata and
not just .data?  could it be changed?  it seems the ia64 port is the
only port that does this.

