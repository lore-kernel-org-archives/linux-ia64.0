From: CH Gowri Kumar <gkumar@csa.iisc.ernet.in>
Date: Sat, 10 May 2003 04:42:24 +0000
Subject: Re: [Linux-ia64] executable data segment ?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="277917251-460122983-1052541024=:5914"
Message-Id: <marc-linux-ia64-105590723705719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705718@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705718@msgid-missing>
To: linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--277917251-460122983-1052541024=:5914
Content-Type: TEXT/PLAIN; charset=US-ASCII

> 	Is there a way in linux on ia64 to execute code in the
> datasegment ? 
Yes, it is possible to execute code in the data segment.
The data segment by default is not executable. You might have to 
make it executable using the mprotect system call.

The following example might be of some use to you:
(the C file is provided as ataachment also)

-----------Cut Here------------
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <malloc.h>
#include <sys/mman.h>


unsigned long shellcode[] = {
  /* MLX
   ** alloc r34 = ar.pfs, 0, 3, 3, 0   // allocate vars for
   *  syscall
   ** movl r14 = 0x0168732f6e69622f    // aka
   *    "/bin/sh",0x01
   ** ;; */
  0x2f6e458006191005, 0x631132f1c0016873,
  /* MLX
   *    * xor r37 = r37, r37               // NULL
   *       * movl r17 = 0x48f017994897c001    // bundle[0]
   *          * ;; */
  0x9948a00f4a952805, 0x6602e0122048f017,
  /* MII
   *    * adds r15 = 0x1094, r37           // unfinished
   *    bundle[1]
   *       * or r22 = 0x08, r37               // part 1 of
   *       bundle[1]
   *          * dep r12 = r37, r12, 0, 8         // align
   *          stack ptr
   *             * ;; */
  0x416021214a507801, 0x4fdc625180405c94,
  /* MII
   *    * adds r35 = -40, r12              // circling
   *    mem addr 1, shellstr addr
   *       * adds r36 = -32, r12              //
   *       circling mem addr 2, args[0] addr
   *          * dep r15 = r22, r15, 56, 8        //
   *          patch bundle[1] (part 1)
   *             * ;; */
  0x0240233f19611801, 0x41dc7961e0467e33,
  /* MII
   *    * st8 [r36] = r35, 16              //
   *    args[0] = shellstring addr
   *       * adds r19 = -16, r12              //
   *       prepare branch addr: bundle[0] addr
   *          * or r23 = 0x42, r37
   *          // part 2 of bundle[1]
   *             * ;; */
  0x81301598488c8001, 0x80b92c22e0467e33,
  /* MII
   *    * st8 [r36] = r17, 8               //
   *    store bundle[0]
   *       * dep r14 = r37, r14, 56, 8
   *       // fix shellstring
   *          * dep r15 = r23, r15, 16, 8
   *          // patch bundle[1] (part 2)
   *             * ;; */
  0x28e0159848444001, 0x4bdc7971e020ee39,
  /* MMI
   *    * st8 [r35] = r14, 25
   *    // store shellstring
   *       * cmp.eq p2, p8 = r37, r37
   *       // prepare predicate for final
   *       branch.
   *          * mov b6 = r19
   *          // (+0x01) setup branch reg
   *             * ;; */
  0x282015984638c801, 0x07010930c0701095,
  /* MIB
   *    * st8 [r36] = r15, -16
   *    // store bundle[1]
   *       * adds r35 = -25, r35
   *       // correct string addr
   *          * (p2) br.cond.spnt.few
   *          b6         // (+0x01)
   *          branch to constr. bundle
   *             * ;; */
  0x3a301799483f8011, 0x0180016001467e8f,
};

/*
 ** the constructed bundle
 **
 ** MII
 ** st8 [r36] = r37, -8                // args[1] = NULL
 ** adds r15 = 1033, r37               // syscall number
 ** break.i 0x100000
 ** ;;
 **
 ** encoding is:
 ** bundle[0] = 0x48f017994897c001
 ** bundle[1] = 0x0800000000421094
 **/


/* Function pointer in IA-64 in a FAT pointer */
typedef struct _fp
{
  long addr;
  long gp;
}
IA64_FUNCTION;

static void flush_cache (void *addr, unsigned long len)
{
	void *end = (char *) addr + len;
	while (addr < end)
	{
    	asm volatile ("fc %0"::"r" (addr));
      	addr = (char *) addr + 32;
    }
  	asm volatile (";;sync.i;;srlz.i;;");
}

void Dummy (void)
{
  	return;
}

int main (int argc, char *argv[])
{
	void (*pSubroutine) (void);
	unsigned long *pBuffer1;
	IA64_FUNCTION *fp;
	IA64_FUNCTION newfp;
	
	pBuffer1 = (unsigned long *) malloc (256);
	memcpy (pBuffer1, (unsigned char *) shellcode, 256);
	flush_cache (pBuffer1, 256);
	   
	fp = (IA64_FUNCTION *) Dummy;
	newfp.gp = fp->gp;
	newfp.addr = (long) pBuffer1;
	
	pSubroutine = (void (*)(void)) &newfp;
	mprotect ((void *) ((long) pBuffer1 & ~(getpagesize () - 1)),
			getpagesize (), PROT_READ | PROT_WRITE | PROT_EXEC);
	
	(*pSubroutine) ();
	return 0;
}
-------------Cut Here----------

Regards,
Gowri Kumar

--277917251-460122983-1052541024=:5914
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="shellcode.c"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0305101000241.5914@hotspot.csa.iisc.ernet.in>
Content-Description: 
Content-Disposition: attachment; filename="shellcode.c"

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RkbGliLmg+DQojaW5j
bHVkZSA8c3RyaW5nLmg+DQojaW5jbHVkZSA8dW5pc3RkLmg+DQojaW5jbHVk
ZSA8bWFsbG9jLmg+DQojaW5jbHVkZSA8c3lzL21tYW4uaD4NCnVuc2lnbmVk
IGxvbmcgc2hlbGxjb2RlW10gPSB7DQogIC8qIE1MWA0KICAgKiogYWxsb2Mg
cjM0ID0gYXIucGZzLCAwLCAzLCAzLCAwICAgLy8gYWxsb2NhdGUgdmFycyBm
b3INCiAgICogIHN5c2NhbGwNCiAgICoqIG1vdmwgcjE0ID0gMHgwMTY4NzMy
ZjZlNjk2MjJmICAgIC8vIGFrYQ0KICAgKiAgICAiL2Jpbi9zaCIsMHgwMQ0K
ICAgKiogOzsgKi8NCiAgMHgyZjZlNDU4MDA2MTkxMDA1LCAweDYzMTEzMmYx
YzAwMTY4NzMsDQogIC8qIE1MWA0KICAgKiAgICAqIHhvciByMzcgPSByMzcs
IHIzNyAgICAgICAgICAgICAgIC8vIE5VTEwNCiAgICogICAgICAgKiBtb3Zs
IHIxNyA9IDB4NDhmMDE3OTk0ODk3YzAwMSAgICAvLyBidW5kbGVbMF0NCiAg
ICogICAgICAgICAgKiA7OyAqLw0KICAweDk5NDhhMDBmNGE5NTI4MDUsIDB4
NjYwMmUwMTIyMDQ4ZjAxNywNCiAgLyogTUlJDQogICAqICAgICogYWRkcyBy
MTUgPSAweDEwOTQsIHIzNyAgICAgICAgICAgLy8gdW5maW5pc2hlZA0KICAg
KiAgICBidW5kbGVbMV0NCiAgICogICAgICAgKiBvciByMjIgPSAweDA4LCBy
MzcgICAgICAgICAgICAgICAvLyBwYXJ0IDEgb2YNCiAgICogICAgICAgYnVu
ZGxlWzFdDQogICAqICAgICAgICAgICogZGVwIHIxMiA9IHIzNywgcjEyLCAw
LCA4ICAgICAgICAgLy8gYWxpZ24NCiAgICogICAgICAgICAgc3RhY2sgcHRy
DQogICAqICAgICAgICAgICAgICogOzsgKi8NCiAgMHg0MTYwMjEyMTRhNTA3
ODAxLCAweDRmZGM2MjUxODA0MDVjOTQsDQogIC8qIE1JSQ0KICAgKiAgICAq
IGFkZHMgcjM1ID0gLTQwLCByMTIgICAgICAgICAgICAgIC8vIGNpcmNsaW5n
DQogICAqICAgIG1lbSBhZGRyIDEsIHNoZWxsc3RyIGFkZHINCiAgICogICAg
ICAgKiBhZGRzIHIzNiA9IC0zMiwgcjEyICAgICAgICAgICAgICAvLw0KICAg
KiAgICAgICBjaXJjbGluZyBtZW0gYWRkciAyLCBhcmdzWzBdIGFkZHINCiAg
ICogICAgICAgICAgKiBkZXAgcjE1ID0gcjIyLCByMTUsIDU2LCA4ICAgICAg
ICAvLw0KICAgKiAgICAgICAgICBwYXRjaCBidW5kbGVbMV0gKHBhcnQgMSkN
CiAgICogICAgICAgICAgICAgKiA7OyAqLw0KICAweDAyNDAyMzNmMTk2MTE4
MDEsIDB4NDFkYzc5NjFlMDQ2N2UzMywNCiAgLyogTUlJDQogICAqICAgICog
c3Q4IFtyMzZdID0gcjM1LCAxNiAgICAgICAgICAgICAgLy8NCiAgICogICAg
YXJnc1swXSA9IHNoZWxsc3RyaW5nIGFkZHINCiAgICogICAgICAgKiBhZGRz
IHIxOSA9IC0xNiwgcjEyICAgICAgICAgICAgICAvLw0KICAgKiAgICAgICBw
cmVwYXJlIGJyYW5jaCBhZGRyOiBidW5kbGVbMF0gYWRkcg0KICAgKiAgICAg
ICAgICAqIG9yIHIyMyA9IDB4NDIsIHIzNw0KICAgKiAgICAgICAgICAvLyBw
YXJ0IDIgb2YgYnVuZGxlWzFdDQogICAqICAgICAgICAgICAgICogOzsgKi8N
CiAgMHg4MTMwMTU5ODQ4OGM4MDAxLCAweDgwYjkyYzIyZTA0NjdlMzMsDQog
IC8qIE1JSQ0KICAgKiAgICAqIHN0OCBbcjM2XSA9IHIxNywgOCAgICAgICAg
ICAgICAgIC8vDQogICAqICAgIHN0b3JlIGJ1bmRsZVswXQ0KICAgKiAgICAg
ICAqIGRlcCByMTQgPSByMzcsIHIxNCwgNTYsIDgNCiAgICogICAgICAgLy8g
Zml4IHNoZWxsc3RyaW5nDQogICAqICAgICAgICAgICogZGVwIHIxNSA9IHIy
MywgcjE1LCAxNiwgOA0KICAgKiAgICAgICAgICAvLyBwYXRjaCBidW5kbGVb
MV0gKHBhcnQgMikNCiAgICogICAgICAgICAgICAgKiA7OyAqLw0KICAweDI4
ZTAxNTk4NDg0NDQwMDEsIDB4NGJkYzc5NzFlMDIwZWUzOSwNCiAgLyogTU1J
DQogICAqICAgICogc3Q4IFtyMzVdID0gcjE0LCAyNQ0KICAgKiAgICAvLyBz
dG9yZSBzaGVsbHN0cmluZw0KICAgKiAgICAgICAqIGNtcC5lcSBwMiwgcDgg
PSByMzcsIHIzNw0KICAgKiAgICAgICAvLyBwcmVwYXJlIHByZWRpY2F0ZSBm
b3IgZmluYWwNCiAgICogICAgICAgYnJhbmNoLg0KICAgKiAgICAgICAgICAq
IG1vdiBiNiA9IHIxOQ0KICAgKiAgICAgICAgICAvLyAoKzB4MDEpIHNldHVw
IGJyYW5jaCByZWcNCiAgICogICAgICAgICAgICAgKiA7OyAqLw0KICAweDI4
MjAxNTk4NDYzOGM4MDEsIDB4MDcwMTA5MzBjMDcwMTA5NSwNCiAgLyogTUlC
DQogICAqICAgICogc3Q4IFtyMzZdID0gcjE1LCAtMTYNCiAgICogICAgLy8g
c3RvcmUgYnVuZGxlWzFdDQogICAqICAgICAgICogYWRkcyByMzUgPSAtMjUs
IHIzNQ0KICAgKiAgICAgICAvLyBjb3JyZWN0IHN0cmluZyBhZGRyDQogICAq
ICAgICAgICAgICogKHAyKSBici5jb25kLnNwbnQuZmV3DQogICAqICAgICAg
ICAgIGI2ICAgICAgICAgLy8gKCsweDAxKQ0KICAgKiAgICAgICAgICBicmFu
Y2ggdG8gY29uc3RyLiBidW5kbGUNCiAgICogICAgICAgICAgICAgKiA7OyAq
Lw0KICAweDNhMzAxNzk5NDgzZjgwMTEsIDB4MDE4MDAxNjAwMTQ2N2U4ZiwN
Cn07DQoNCi8qDQogKiogdGhlIGNvbnN0cnVjdGVkIGJ1bmRsZQ0KICoqDQog
KiogTUlJDQogKiogc3Q4IFtyMzZdID0gcjM3LCAtOCAgICAgICAgICAgICAg
ICAvLyBhcmdzWzFdID0gTlVMTA0KICoqIGFkZHMgcjE1ID0gMTAzMywgcjM3
ICAgICAgICAgICAgICAgLy8gc3lzY2FsbCBudW1iZXINCiAqKiBicmVhay5p
IDB4MTAwMDAwDQogKiogOzsNCiAqKg0KICoqIGVuY29kaW5nIGlzOg0KICoq
IGJ1bmRsZVswXSA9IDB4NDhmMDE3OTk0ODk3YzAwMQ0KICoqIGJ1bmRsZVsx
XSA9IDB4MDgwMDAwMDAwMDQyMTA5NA0KICoqLw0KDQoNCi8qIEZ1bmN0aW9u
IHBvaW50ZXIgaW4gSUEtNjQgaW4gYSBGQVQgcG9pbnRlciAqLw0KdHlwZWRl
ZiBzdHJ1Y3QgX2ZwDQp7DQogIGxvbmcgYWRkcjsNCiAgbG9uZyBncDsNCn0N
CklBNjRfRlVOQ1RJT047DQoNCnN0YXRpYyB2b2lkIGZsdXNoX2NhY2hlICh2
b2lkICphZGRyLCB1bnNpZ25lZCBsb25nIGxlbikNCnsNCgl2b2lkICplbmQg
PSAoY2hhciAqKSBhZGRyICsgbGVuOw0KCXdoaWxlIChhZGRyIDwgZW5kKQ0K
CXsNCiAgICAJYXNtIHZvbGF0aWxlICgiZmMgJTAiOjoiciIgKGFkZHIpKTsN
CiAgICAgIAlhZGRyID0gKGNoYXIgKikgYWRkciArIDMyOw0KICAgIH0NCiAg
CWFzbSB2b2xhdGlsZSAoIjs7c3luYy5pOztzcmx6Lmk7OyIpOw0KfQ0KDQp2
b2lkIER1bW15ICh2b2lkKQ0Kew0KICAJcmV0dXJuOw0KfQ0KDQppbnQgbWFp
biAoaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkNCnsNCgl2b2lkICgqcFN1YnJv
dXRpbmUpICh2b2lkKTsNCgl1bnNpZ25lZCBsb25nICpwQnVmZmVyMTsNCglJ
QTY0X0ZVTkNUSU9OICpmcDsNCglJQTY0X0ZVTkNUSU9OIG5ld2ZwOw0KCQ0K
CXBCdWZmZXIxID0gKHVuc2lnbmVkIGxvbmcgKikgbWFsbG9jICgyNTYpOw0K
CW1lbWNweSAocEJ1ZmZlcjEsICh1bnNpZ25lZCBjaGFyICopIHNoZWxsY29k
ZSwgMjU2KTsNCglmbHVzaF9jYWNoZSAocEJ1ZmZlcjEsIDI1Nik7DQoJICAg
DQoJZnAgPSAoSUE2NF9GVU5DVElPTiAqKSBEdW1teTsNCgluZXdmcC5ncCA9
IGZwLT5ncDsNCgluZXdmcC5hZGRyID0gKGxvbmcpIHBCdWZmZXIxOw0KCQ0K
CXBTdWJyb3V0aW5lID0gKHZvaWQgKCopKHZvaWQpKSAmbmV3ZnA7DQoJbXBy
b3RlY3QgKCh2b2lkICopICgobG9uZykgcEJ1ZmZlcjEgJiB+KGdldHBhZ2Vz
aXplICgpIC0gMSkpLA0KCQkJZ2V0cGFnZXNpemUgKCksIFBST1RfUkVBRCB8
IFBST1RfV1JJVEUgfCBQUk9UX0VYRUMpOw0KCQ0KCSgqcFN1YnJvdXRpbmUp
ICgpOw0KCXJldHVybiAwOw0KfQ0K
--277917251-460122983-1052541024=:5914--

