From: "Qiu HongBing" <qiuhb@necas.nec.co.jp>
Date: Tue, 13 Nov 2001 00:57:40 +0000
Subject: [Linux-ia64] do me a favor
Message-Id: <marc-linux-ia64-105590698805482@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

I'm Qiu HongBing. Now I process some project from IA32 to IA64 on Linux. Now
I have one question. If someone know it why and have spare time, Please help
me.Thanks a lot.

My problem is as follows:

struct aa{
unsigned short a;
unsigned short b;
unsigned short c;
unsigned short d;
unsigned int e;
unsigned int f;
unsigned int g;
unsigned int h;
unsigned short i;
}
...
struct aa *a1;
...

fun1(char *,unsigned int *,char *,char *,unsigned int * temp,unsigned int *)
{
...
*temp=10;
...
}
...

fun1(a,b,c,d,&a1->b,e);
...

On IA64 Linux RedHat 7.1(2.4.3-3), when the program run to
fun1(a,b,c,d,&a1->b,e), the kernel write into syslog some message which is
"Nov  5 10:12:02 sdv2 kernel: ESMmlx(7837): unaligned access to
0x600000000001684c, ip=3D0x2000000000624370".

But if I modify the source as follows and it is OK. I dont know why. So I
want to get some help to solve the real cause.

...
{
    unsigned int tt;
    tt=A1->b;

    fun1(a,b,c,d,&a1->b,e);

    a1->b=3Dtt;
}
...

    That's all.





