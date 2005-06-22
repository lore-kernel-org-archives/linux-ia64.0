From: Smarduch Mario-CMS063 <CMS063@motorola.com>
Date: Wed, 22 Jun 2005 20:37:48 +0000
Subject: RE: 2.4.31 TLB corruption
Message-Id: <A752C16E6296D711942200065BFCB6941D79BA32@il02exm10>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C5776A.3FF720AA"
List-Id: <linux-ia64.vger.kernel.org>
References: <A752C16E6296D711942200065BFCB6941D79B9F3@il02exm10>
In-Reply-To: <A752C16E6296D711942200065BFCB6941D79B9F3@il02exm10>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C5776A.3FF720AA
Content-Type: text/plain


Attached is a patch produced by HP LOSL its not quite against
2.4.31  but I it probably should apply cleanly, the related code
is indentical to latest 2.4 kernel. If needed I could inquire
for them to develop a 2.6 patch (I myself don't have 2.6 kernel up)
please ask if needed. 

To reproduce the RID range was shrunk to lim/maxctx=1023/2048.
on an 8-way about 180 copies with an argument of 5 was ran.
We'd also appreciate feedback on the patch itself. There is stil
another scenario on NUMA systems I'm concerned about I'll ask
on the maillist when time permits.

- mario
-------------------------------------

#include <stdio.h>
#include <errno.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

volatile unsigned long udummy1, udummy2, udummy3;
volatile unsigned long idummy1=100, idummy2=200, idummy3=300;

void * worker(void *self) {
  int x = -1;
  FILE *pp = 0;
  long junk[8192];
  char buf[1024];

    x = -1;
    errno = 0;
    //printf("Thread: %u\n", getpid());
    pp = popen("ls", "r");
    x = errno;
    if(pp) {
      memset(buf, 0, sizeof(buf));
      while(fgets(buf, sizeof(buf)-1, pp) != 0) {
        ;
        }
      pclose(pp);
    udummy1=101;
    udummy2=102;
    udummy3=103;
    idummy1++;
    idummy2++;
    idummy3++;
usleep(5000);

    }
    else printf("popen failed: %s\n", strerror(errno));
    //printf("Thread Exit: %ud\n", getpid());
    pthread_exit(NULL);
}

int main(int argc, char **argv) {
  pthread_t pt[512];
  pthread_t pthr;
  int x = 0;
  int thrcnt=5;

  if(argc > 1)
    thrcnt=atoi(argv[1]);
  if(!thrcnt)
        thrcnt=5;

  while(1) {
        //printf("Creating Thread...");
        for (x = 0; x < thrcnt; x++)
                pthread_create(&(pt[x]), 0, worker, (void *)&x);
        for (x = 0; x < thrcnt; x++)
                pthread_join( pt[x], NULL);
        usleep(5000);
        }
  return 0;
}




-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
Sent: Wednesday, June 22, 2005 12:56 PM
To: Smarduch Mario-CMS063
Cc: davidm@hpl.hp.com; linux-ia64@vger.kernel.org
Subject: RE: 2.4.31 TLB corruption


>>>>> On Tue, 21 Jun 2005 16:22:50 -0500, Smarduch Mario-CMS063 
>>>>> <CMS063@motorola.com> said:

  Mario> FYI, shrinking the RID range does reproduce the problem
  Mario> easily. Its also reproducable on 2.6.7.

That's progress.  Could you provide the kernel patch and description of minimal test-case to reproduce the problem?

Thanks,

	--david


------_=_NextPart_000_01C5776A.3FF720AA
Content-Type: application/octet-stream;
	name="tlb_flush_bug2409.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="tlb_flush_bug2409.patch"

LS0tIGxpbnV4LTIuNC4yMC9hcmNoL2lhNjQvbW0vdGxiLmMJVHVlIE1heSAgMyAxNDoyNzowMSAy
MDA1DQorKysgbGludXgtMi40LjIwLXRsYnBhdGNoL2FyY2gvaWE2NC9tbS90bGIuYwlNb24gSnVu
IDIwIDEwOjM1OjA4IDIwMDUNCkBAIC0xMTgsNiArMTE4LDcgQEANCiAJc3RyaWRlMCA9IGxvY2Fs
X2NwdV9kYXRhLT5wdGNlX3N0cmlkZVswXTsNCiAJc3RyaWRlMSA9IGxvY2FsX2NwdV9kYXRhLT5w
dGNlX3N0cmlkZVsxXTsNCiANCisJbG9jYWxfY3B1X2RhdGEtPm5lZWRfdGxiX2ZsdXNoID0gMDsN
CiAJbG9jYWxfaXJxX3NhdmUoZmxhZ3MpOw0KIAlmb3IgKGkgPSAwOyBpIDwgY291bnQwOyArK2kp
IHsNCiAJCWZvciAoaiA9IDA7IGogPCBjb3VudDE7ICsraikgew0KLS0tIGxpbnV4LTIuNC4yMC9p
bmNsdWRlL2FzbS1pYTY0L21tdV9jb250ZXh0LmgJTW9uIEp1biAxMyAxNjo1MTowNCAyMDA1DQor
KysgbGludXgtMi40LjIwLXRsYnBhdGNoL2luY2x1ZGUvYXNtLWlhNjQvbW11X2NvbnRleHQuaAlN
b24gSnVuIDIwIDEwOjM4OjMxIDIwMDUNCkBAIC01NSw3ICs1NSw2IEBADQogDQogCWlmICh1bmxp
a2VseShsb2NhbF9jcHVfZGF0YS0+bmVlZF90bGJfZmx1c2gpKSB7DQogCQlsb2NhbF9mbHVzaF90
bGJfYWxsKCk7DQotCQlsb2NhbF9jcHVfZGF0YS0+bmVlZF90bGJfZmx1c2ggPSAwOw0KIAl9DQog
fQ0KIA0KQEAgLTEzMiw2ICsxMzEsNyBAQA0KIA0KIAlkbyB7DQogCQljb250ZXh0ID0gZ2V0X21t
dV9jb250ZXh0KG1tKTsNCisJCWRlbGF5ZWRfdGxiX2ZsdXNoKCk7IC8qIGZsdXNoIHRsYiBiZWZv
cmUgbG9hZGluZyByZWxvYWRpbmcgKi8NCiAJCXJlbG9hZF9jb250ZXh0KGNvbnRleHQpOw0KIAkJ
LyogaW4gdGhlIHVubGlrZWx5IGV2ZW50IG9mIGEgVExCLWZsdXNoIGJ5IGFub3RoZXIgdGhyZWFk
LCByZWRvIHRoZSBsb2FkOiAqLw0KIAl9IHdoaWxlICh1bmxpa2VseShjb250ZXh0ICE9IG1tLT5j
b250ZXh0KSk7DQpAQCAtMTQzLDggKzE0Myw2IEBADQogc3RhdGljIGlubGluZSB2b2lkDQogYWN0
aXZhdGVfbW0gKHN0cnVjdCBtbV9zdHJ1Y3QgKnByZXYsIHN0cnVjdCBtbV9zdHJ1Y3QgKm5leHQp
DQogew0KLQlkZWxheWVkX3RsYl9mbHVzaCgpOw0KLQ0KIAkvKg0KIAkgKiBXZSBtYXkgZ2V0IGlu
dGVycnVwdHMgaGVyZSwgYnV0IHRoYXQncyBPSyBiZWNhdXNlIGludGVycnVwdCBoYW5kbGVycyBj
YW5ub3QNCiAJICogdG91Y2ggdXNlci1zcGFjZS4NCg==

------_=_NextPart_000_01C5776A.3FF720AA--
