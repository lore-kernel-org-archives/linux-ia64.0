From: "David J. Morse" <david.morse@onebox.com>
Date: Thu, 18 Oct 2001 21:50:28 +0000
Subject: [Linux-ia64] sscanf() broken on ia64
Message-Id: <marc-linux-ia64-105590698805369@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I'm having a problem with sscanf() on IA-64; it seems to be able to parse
a string into arguments correctly when whitespace is the delimiter, but
not "."!

Below is a small module to illustrate what I mean (you must be running
2.4.10 or greater, since that's when sscanf was added).  On IA-64 I get

sscanf returned 1, d1=192, d2=3D0, d30, d4=3D0, port=3D0
sscanf returned 5, d1=192, d2=3D1, d3=3D1, d4=132, port=80

when I should get the latter both times (as I do on x86).

Can someone help?

Thanks,

David
-----------------------------------------------------------------
/* sscanf.c=20
 *=20
 * Tests sscanf() functionality as a loadable kernel module.
 *
 *  gcc -Wall -Wstrict-prototypes -O6 -I/lib/modules/`uname -r`/build/inclu=
de
-c -o sscanf.o sscanf.c
 */

/* Declare what kind of code we want from the header files */
#define __KERNEL__         /* We're part of the kernel */
#define MODULE             /* Not a permanent part, though. */

/* Standard headers for LKMs */
#include <linux/modversions.h>=20
#include <linux/module.h> =20

/* Initialize the LKM */
int init_module()
{
        unsigned int d1, d2, d3, d4, port;
	int retval =3D 0;

	/* This does not work on IA-64 */
	retval =3D sscanf("192.1.1.132:80", "%d.%d.%d.%d:%d",
                                        &d1, &d2, &d3, &d4, &port);
	printk(KERN_INFO "sscanf returned %d, d1=3D%d, d2=3D%d, d3=3D%d, d4=3D%d,
port=3D%d\n", retval, d1, d2, d3, d4, port);

	/* This does work on IA-64 */

	retval =3D sscanf("192 1 1 132 80", "%d %d %d %d %d",
                                        &d1, &d2, &d3, &d4, &port);
	printk(KERN_INFO "sscanf returned %d, d1=3D%d, d2=3D%d, d3=3D%d, d4=3D%d,
port=3D%d\n", retval, d1, d2, d3, d4, port);

  return 0;
}


/* Cleanup - undo whatever init_module did */
void cleanup_module()
{
  printk(KERN_INFO "Removing sscanf module\n");
}


__________________________________________________
FREE voicemail, email, and fax...all in one place.
Sign Up Now! http://www.onebox.com


