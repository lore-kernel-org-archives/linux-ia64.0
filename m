From: Maciej Golebiewski <maciej@ccrl-nece.technopark.gmd.de>
Date: Fri, 12 Jan 2001 16:20:20 +0000
Subject: [Linux-ia64] /proc/pid/mem and stack variables
Message-Id: <marc-linux-ia64-105590693005037@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello everyone,

I'm new on this list. I looked through the archives but could not
find answer to my problem.

I have a library that makes use of /proc/pid/mem entries in the
/proc pseudo-filesystem. It runs perfectly on IA32 under 2.2.12
(and some superficial tests suggest that it works under
2.4.0-test12 as well).

I have recompiled the library on IA64 under 2.4.0-test12
and using version 2.9-ia64-000216-final. The library works
OK except when the address it tries to access via /proc/pid/mem
refers to variables allocated on stack (e.g. local arrays defined
in functions).

This is a snippet of code used to access memory via /proc/pid/mem:

void mem_read (int fd, void *buf, void *addr, size_t len) {

	if (lseek (fd, (off_t)addr, SEEK_SET) =3D=3D (off_t)-1)
                perror ("lseek");
	read (fd, buf, len);

lseek in this code fails (EINVAL) always when addr is address of
a variable allocated on stack.

I have no idea if the problem is because I'm doing something
wrong, or because /proc/pid/mem is not yet fully implemented on IA64.
I appreciate any hints and help with this.

Thanks in advance,

Maciej

--=20
Maciej Go=B3=EAbiewski
golebiewski@ccrl-nece.de
http://www.ccrl-nece.technopark.gmd.de/~maciej
C&C Research Laboratories, NEC Europe Ltd., Sankt Augustin, Germany

