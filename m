From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 May 2003 21:51:58 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705977@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some minor issues with the "salinfo" tool.

1) It doesn't compile :-(

 mca.c: In function `ia64_log_processor_info_print':
 mca.c:961: `printf' undeclared (first use in this function)
 mca.c:961: (Each undeclared identifier is reported only once
 mca.c:961: for each function it appears in.)
 make: *** [mca.o] Error 1

I added an "extern int printf(char *, ...);" declaration rather
than risking including <stdio.h>

2) I crashed my machine with an injected machine check, and
then rebooted.  All four of the /proc/sal/cpuX/mca files had
a copy of the same error record.  Echoing "clear" to one of
them made them all go away.

I think this is normal ... but it may require some interesting
documentation to say why things work like this.

3) The salinfo tool uses exponential increases in the size of the
read that it tries from the /proc/sal/cpuX/mca file.  My particular
error record was 5560 bytes long and strace reports:

  read(3, ""..., 1024) = 1024
  read(3, ""..., 1024) = 1024
  read(3, ""..., 2048) = 2048
  read(3, ""..., 4096) = 1464
  read(3, "", 2632)    = 0

A hypothetically large enough record would result in salinfo reading
more than a page in one piece through /proc, which I think breaks the
way arch/ia64/kernel/salinfo.c is interfacing with /proc.  Perhaps
the salinfo utility should just grow the buffer in 1k increments with
	alloc += 1024;
rather than using
	alloc *= 2;

4) Reading this way is also kind of weird in that every partial read
results in the kernel going back to re-fetch the data from the SAL
with another call to ia64_sal_get_state_info().  One kludgy fix would
be to have the salinfo tool use "getpagesize()" as the initial size
and increment for the buffer it uses (at least for kernels with a 16k
page size ... error records should generally be small enough for a
single slurp). Though we'd still do one extra call to get the nbytes==0
return to signify the EOF (unless we assume the partial read got us
all the data?)

