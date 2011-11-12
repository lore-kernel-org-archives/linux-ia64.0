From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Sat, 12 Nov 2011 14:17:25 +0000
Subject: [PATCH] ia64: Add accept4() syscall
Message-Id: <CAA9xbM5w3j6GbXs3764N-Z-ePTagi3cjyid-a2Ci_jTtZ8Y5Rg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

From: =C9meric Maschino <emeric.maschino@gmail.com>
Subject: ia64: Add accept4() syscall

While debugging udev > 170 failure on Debian Wheezy
(http://bugs.debian.org/cgi-bin/bugreport.cgi?bugd8325), it appears
that the issue was in fact due to missing accept4() in ia64.

This patch simply adds accept4() to ia64. The
arch/ia64/include/asm/unistd.h and arch/ia64/kernel/entry.S diffs
apply cleanly against 3.2-rc1.

Patch has been successfully tested running an ia64-targeted version of
test_accept4.c (modified from x86/x86_64-centric original version from
http://git.kernel.org/linus/de11defebf00007677fb7ee91d9b089b78786fbb):

/* test_accept4.c

  Copyright (C) 2008, Linux Foundation, written by Michael Kerrisk
       <mtk.manpages@gmail.com>

  Licensed under the GNU GPLv2 or later.
*/
#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>

#define PORT_NUM 33333

#define die(msg) do { perror(msg); exit(EXIT_FAILURE); } while (0)

/**********************************************************************/

/* The following is what we need until glibc gets a wrapper for
  accept4() */

/* Flags for socket(), socketpair(), accept4() */
#ifndef SOCK_CLOEXEC
#define SOCK_CLOEXEC    O_CLOEXEC
#endif

#ifndef SOCK_NONBLOCK
#define SOCK_NONBLOCK   O_NONBLOCK
#endif

#define __NR_accept4 1334

static int
__accept4(int fd, struct sockaddr *sockaddr, socklen_t *addrlen, int flags)
{
   printf("Calling accept4(): flags =3D %x", flags);
   if (flags !=3D 0) {
       printf(" (");
       if (flags & SOCK_CLOEXEC)
           printf("SOCK_CLOEXEC");
       if ((flags & SOCK_CLOEXEC) && (flags & SOCK_NONBLOCK))
           printf(" ");
       if (flags & SOCK_NONBLOCK)
           printf("SOCK_NONBLOCK");
       printf(")");
   }
   printf("\n");

   return syscall(__NR_accept4, fd, sockaddr, addrlen, flags);
}

/**********************************************************************/

static int
do_test(int lfd, struct sockaddr_in *conn_addr,
       int closeonexec_flag, int nonblock_flag)
{
   int connfd, acceptfd;
   int fdf, flf, fdf_pass, flf_pass;
   struct sockaddr_in claddr;
   socklen_t addrlen;

   printf("=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");

   connfd =3D socket(AF_INET, SOCK_STREAM, 0);
   if (connfd =3D -1)
       die("socket");
   if (connect(connfd, (struct sockaddr *) conn_addr,
               sizeof(struct sockaddr_in)) =3D -1)
       die("connect");

   addrlen =3D sizeof(struct sockaddr_in);
   acceptfd =3D __accept4(lfd, (struct sockaddr *) &claddr, &addrlen,
                      closeonexec_flag | nonblock_flag);
   if (acceptfd =3D -1) {
       perror("accept4()");
       close(connfd);
       return 0;
   }

   fdf =3D fcntl(acceptfd, F_GETFD);
   if (fdf =3D -1)
       die("fcntl:F_GETFD");
   fdf_pass =3D ((fdf & FD_CLOEXEC) !=3D 0) =3D
              ((closeonexec_flag & SOCK_CLOEXEC) !=3D 0);
   printf("Close-on-exec flag is %sset (%s); ",
           (fdf & FD_CLOEXEC) ? "" : "not ",
           fdf_pass ? "OK" : "failed");

   flf =3D fcntl(acceptfd, F_GETFL);
   if (flf =3D -1)
       die("fcntl:F_GETFD");
   flf_pass =3D ((flf & O_NONBLOCK) !=3D 0) =3D
              ((nonblock_flag & SOCK_NONBLOCK) !=3D0);
   printf("nonblock flag is %sset (%s)\n",
           (flf & O_NONBLOCK) ? "" : "not ",
           flf_pass ? "OK" : "failed");

   close(acceptfd);
   close(connfd);

   printf("Test result: %s\n", (fdf_pass && flf_pass) ? "PASS" : "FAIL");
   return fdf_pass && flf_pass;
}

static int
create_listening_socket(int port_num)
{
   struct sockaddr_in svaddr;
   int lfd;
   int optval;

   memset(&svaddr, 0, sizeof(struct sockaddr_in));
   svaddr.sin_family =3D AF_INET;
   svaddr.sin_addr.s_addr =3D htonl(INADDR_ANY);
   svaddr.sin_port =3D htons(port_num);

   lfd =3D socket(AF_INET, SOCK_STREAM, 0);
   if (lfd =3D -1)
       die("socket");

   optval =3D 1;
   if (setsockopt(lfd, SOL_SOCKET, SO_REUSEADDR, &optval,
                  sizeof(optval)) =3D -1)
       die("setsockopt");

   if (bind(lfd, (struct sockaddr *) &svaddr,
            sizeof(struct sockaddr_in)) =3D -1)
       die("bind");

   if (listen(lfd, 5) =3D -1)
       die("listen");

   return lfd;
}

int
main(int argc, char *argv[])
{
   struct sockaddr_in conn_addr;
   int lfd;
   int port_num;
   int passed;

   passed =3D 1;

   port_num =3D (argc > 1) ? atoi(argv[1]) : PORT_NUM;

   memset(&conn_addr, 0, sizeof(struct sockaddr_in));
   conn_addr.sin_family =3D AF_INET;
   conn_addr.sin_addr.s_addr =3D htonl(INADDR_LOOPBACK);
   conn_addr.sin_port =3D htons(port_num);

   lfd =3D create_listening_socket(port_num);

   if (!do_test(lfd, &conn_addr, 0, 0))
       passed =3D 0;
   if (!do_test(lfd, &conn_addr, SOCK_CLOEXEC, 0))
       passed =3D 0;
   if (!do_test(lfd, &conn_addr, 0, SOCK_NONBLOCK))
       passed =3D 0;
   if (!do_test(lfd, &conn_addr, SOCK_CLOEXEC, SOCK_NONBLOCK))
       passed =3D 0;

   close(lfd);

   exit(passed ? EXIT_SUCCESS : EXIT_FAILURE);
}

Signed-off-by: =C9meric Maschino <emeric.maschino@gmail.com>
---

diff -uprN -X linux-3.2-rc1/Documentation/dontdiff
a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
--- a/arch/ia64/include/asm/unistd.h	2011-11-08 01:16:02.000000000 +0100
+++ b/arch/ia64/include/asm/unistd.h	2011-11-12 11:31:53.000000000 +0100
@@ -323,11 +323,12 @@
 #define __NR_sendmmsg			1331
 #define __NR_process_vm_readv		1332
 #define __NR_process_vm_writev		1333
+#define __NR_accept4			1334

 #ifdef __KERNEL__


-#define NR_syscalls			310 /* length of syscall table */
+#define NR_syscalls			311 /* length of syscall table */

 /*
  * The following defines stop scripts/checksyscalls.sh from complaining ab=
out
diff -uprN -X linux-3.2-rc1/Documentation/dontdiff
a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2011-11-08 01:16:02.000000000 +0100
+++ b/arch/ia64/kernel/entry.S	2011-11-12 11:33:40.000000000 +0100
@@ -1779,6 +1779,7 @@ sys_call_table:
 	data8 sys_sendmmsg
 	data8 sys_process_vm_readv
 	data8 sys_process_vm_writev
+	data8 sys_accept4

 	.org sys_call_table + 8*NR_syscalls	// guard against failures to
increase NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
