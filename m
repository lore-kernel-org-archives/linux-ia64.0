From: "Zach, Yoav" <yoav.zach@intel.com>
Date: Sun, 12 Aug 2001 06:58:48 +0000
Subject: [Linux-ia64] incorrect misalignment handling
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C122FC.3C9A1B40"
Message-Id: <marc-linux-ia64-105590698805060@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C122FC.3C9A1B40
Content-Type: text/plain;
	charset="windows-1252"

We encountered a problem with the handling of misaligned operations. When
handling a misaligned 'stfX' instruction, the kernel uses the function
emulate_store_float( ), which practically copies the source to destination
byte by byte. The length of the operation is determined according to the
instruction's fsz completer, using the float_fsz table:

static const unsigned char float_fsz[4]={
	16, /* extended precision (e) */
	8,  /* integer (8)            */
	4,  /* single precision (s)   */
	8   /* double precision (d)   */
}

The problem is that fsz==e means the operation length is 10 bytes, and not
16 bytes as in the implementation. Attached is a small test case that
demonstrates this problem.

My questions are:
*	Is there a rationale behind this implementation, or is it just a
mistake ?
*	If it is a mistake, was it corrected in kernel versions later than
2.4.3 ? 

 <<mis64.c>> 
TIA,
Yoav.

Yoav Zach
Mail:        yoav.zach@intel.com


------_=_NextPart_000_01C122FC.3C9A1B40
Content-Type: application/octet-stream;
	name="mis64.c"
Content-Disposition: attachment;
	filename="mis64.c"

#include <stdio.h>

char buff[20]
/* uncomment the next line to see how it is done in hw */
// __attribute__ ((aligned (16)))
;
int main()
{
    int i;

    for (i = 0; i< 10; i++)
        buff[i] = 'a';
    for (i = 10; i < 20; i++)
        buff[i] = 'A';
    __asm__ ("
        movl r2 = buff;;
        fmerge.s f10 = f0, f1;;
        stfe [r2] = f10;;
    ");
    printf("buff[10] = %c\n", buff[10]);
    return 0;
} 

------_=_NextPart_000_01C122FC.3C9A1B40--

