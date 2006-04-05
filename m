From: Keith Owens <kaos@sgi.com>
Date: Wed, 05 Apr 2006 04:28:54 +0000
Subject: 2.6.16 fails to resume after INIT in user space
Message-Id: <12848.1144211334@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2.6.16 on SN2, compiled with gcc 3.3.3, no KDB.

The SN2 controller 'NMI' command sends INIT to all processors, one as
monarch, the rest as slaves.  If all the processors are in kernel space
(including idle) then INIT resumes after dumping the process list.  If
any of the processors are in user space then INIT claims to resume but
gets something wrong, the system becomes dead.

Send first NMI

  Entered OS INIT handler. PSP=FFe301a0 cpu=3D0 monarch=3D0
  cpu 0, INIT occurred in user space, original stack not modified
  Entered OS INIT handler. PSP=FFe301a0 cpu=3D3 monarch=3D0
  Entered OS INIT handler. PSP=FFe301a0 cpu=3D2 monarch=3D0
  Entered OS INIT handler. PSP=FFe301a0 cpu=3D1 monarch=3D1
  Delaying for 5 seconds...
  Processes interrupted by INIT - 0 (cpu 1 task 0xe00000b47a4b8000) 0 (cpu =
2 task 0xe00000b47a4e8000) 0 (cpu 3 task 0xe00000b47a500000)

  ... process dump ...

  INIT dump complete.  Monarch on cpu 1 returning to normal service.
  Slave on cpu 0 returning to normal service.
  Slave on cpu 3 returning to normal service.
  Slave on cpu 2 returning to normal service.

  ... No response ...

Send second NMI

  Entered OS INIT handler. PSP=FFe301a0 cpu=3D3 monarch=3D0
  Entered OS INIT handler. PSP=FFe301a0 cpu=3D0 monarch=3D0
  cpu 0, INIT inconsistent previous current and r13, original stack not mod=
ified
  Entered OS INIT handler. PSP=FFe301a0 cpu=3D2 monarch=3D0
  Entered OS INIT handler. PSP=FFe301a0 cpu=3D1 monarch=3D1
  Delaying for 5 seconds...
  Processes interrupted by INIT - 0 (cpu 1 task 0xe00000b47a4b8000) 0 (cpu =
2 task 0xe00000b47a4e8000) 0 (cpu 3 task 0xe00000b47a500000)

cpu 0 was running in user space during the first NMI, so the original
stack was not modified.  On the second NMI, current for cpu 0 does not
match r13.  Which means that something went wrong when processing the
first NMI while the process was in user space.

I am still investigating this problem, but any other eyes on the code
would be appreciated.

