From: roneng@ca.ibm.com
Date: Tue, 06 Jun 2000 22:34:01 +0000
Subject: [Linux-ia64] ia64 gcc implementation of alloca
Message-Id: <marc-linux-ia64-105590678205122@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,
Has anyone had any problem using alloca, or knows where in the gcc code it
is implemented?
when I run my program get the following error:

Program received signal SIGSEGV, Segmentation fault.
loose (code, fd=6, name=0x9ffffffffff05ca0 "libnss_files.so.2",
    realname=0x60000000000115b0 "/lib/libnss_files.so.2", l=0x0,
    msg=0x200000000002f880 "cannot read file data") at dl-load.c:642
642       a[0] = fd;
(gdb)

the code around line 642 is the following
__attribute__ ((noreturn))
lose (int code, int fd, const char *name, char *realname, struct link_map
*l,
      const char *msg)
{
  /* The use of `alloca' here looks ridiculous but it helps.  The goal
     is to avoid the function from being inlined.  There is no official
     way to do this so we use this trick.  gcc never inlines functions
     which use `alloca'.  */
int *a = alloca (sizeof (int));
a[0] = fd;

simple testcases of alloca seem to work, so this is probably an
intermittent problem.

Thank you,
Ronen Grosman
- e-mail roneng@ca.ibm.com




