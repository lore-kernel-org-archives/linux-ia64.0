From: Pete_A_Martinez@Dell.com
Date: Thu, 04 Apr 2002 20:09:23 +0000
Subject: [Linux-ia64] unsubscribe
Message-Id: <marc-linux-ia64-105590701905382@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


-----Original Message-----
From: linux-ia64-request@linuxia64.org
[mailto:linux-ia64-request@linuxia64.org]
Sent: Thursday, April 04, 2002 2:01 PM
To: linux-ia64@linuxia64.org
Subject: Linux-IA64 digest, Vol 1 #586 - 12 msgs


Send Linux-IA64 mailing list submissions to
	linux-ia64@linuxia64.org

To subscribe or unsubscribe via the World Wide Web, visit
	http://lists.linuxia64.org/lists/listinfo/linux-ia64
or, via email, send a message with subject or body 'help' to
	linux-ia64-request@linuxia64.org

You can reach the person managing the list at
	linux-ia64-admin@linuxia64.org

When replying, please edit your Subject line so it is more specific
than "Re: Contents of Linux-IA64 digest..."


Today's Topics:

   1. Re: SIGILL errors in strncpu (NAT consumption) (Erich Focht)
   2. Re: SIGILL errors in strncpu (NAT consumption) (David Mosberger)
   3. Re: SIGILL errors in strncpu (NAT consumption) (Jack Steiner)
   4. Re: SIGILL errors in strncpu (NAT consumption) (Francois-Xavier
Kowalski)
   5. Re: [util-linux] [Linux-ia64] mkswap.c ia64 fix  [patch]
(Andries.Brouwer@cwi.nl)
   6. Re: SIGILL errors in strncpu (NAT consumption) (Hideki Yamamoto)
   7. pipe() not setting errno. (=3D?windows-1252?Q?Anders Herbj=F8rnsen?=
=3D)
   8. Re: pipe() not setting errno. (Andreas Schwab)
   9. Re: SIGILL errors in strncpu (NAT consumption) (David Mosberger)
  10. Re: SIGILL errors in strncpu (NAT consumption) (David Mosberger)
  11. Re: SIGILL errors in strncpu (NAT consumption) (Erich Focht)
  12. Re: SIGILL errors in strncpu (NAT consumption) (David Mosberger)

--__--__--

Message: 1
Date: Wed, 3 Apr 2002 23:29:58 +0200 (MEST)
From: Erich Focht <efocht@ess.nec.de>
To: Jack Steiner <steiner@sgi.com>
cc: linux-ia64@linuxia64.org, davidm@hpl.hp.com,
        "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)

> Has anyone seen random SIGILL failures in the strncpy
> function in glibc-2.2.4-19.3?
>
> The failure is caused by a NAT consumption fault in the=20
> code sequence shown below.=20

I've seen NaT consumption faults with an ISV application in a loop
involving speculative loads, too. It was very hard to trace back (occured
at different simulation times in a huge case) and disappeared after we
rewrote the loop and used the latest Intel Fortran compiler. It occured
with both B3 and C0 CPUs under 2.4.7 and 2.4.17. I don't have a testcase
for this, sorry.

Regards,
Erich




--__--__--

Message: 2
From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 3 Apr 2002 14:10:42 -0800
To: Erich Focht <efocht@ess.nec.de>
Cc: Jack Steiner <steiner@sgi.com>, linux-ia64@linuxia64.org,
        davidm@hpl.hp.com, "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Reply-To: davidm@hpl.hp.com

>>>>> On Wed, 3 Apr 2002 23:29:58 +0200 (MEST), Erich Focht
<efocht@ess.nec.de> said:

  Erich> I've seen NaT consumption faults with an ISV application in a
  Erich> loop involving speculative loads, too. It was very hard to
  Erich> trace back (occured at different simulation times in a huge
  Erich> case) and disappeared after we rewrote the loop and used the
  Erich> latest Intel Fortran compiler. It occured with both B3 and C0
  Erich> CPUs under 2.4.7 and 2.4.17. I don't have a testcase for
  Erich> this, sorry.

It's due to a glibc bug that was introduced last August when strncpy()
was rewritten.  I sent a bug report (and preliminary patch) to the
author and am waiting to hear back.

	--david


--__--__--

Message: 3
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
To: linux-ia64@linuxia64.org
Date: Wed, 3 Apr 2002 15:43:37 -0600 (CST)

I isolated the strncpy problem to a simple test program. It fails
with the new glibc-2.2.4-19.3 within a few seconds.

Works fine with older versions of glibc.




David Mosberger took a look at the strncpy code & spotted
the error:

From David:
>> I took a closer look and there seem to be several bugs in the routine:
>>=20
>>  (1) I don't think it's save to do:
>>=20
>>                 chk.s r[MEMLAT], .recovery3
>>                 mov value =3D r[MEMLAT]
>>=20
>>      in the same cycle.  In the patch below, I fixed this by adding a
>>      stop bit, but obviously it would be better to avoid that (either
>>      by re-ordering the code or by adding a pipeline stage).
>>=20
>>  (2) stop bit was missing after br.cloop.dptk
>>=20
>>  (3) off-by-one error in .recovery4 code: the destination should be
>>      r[MEMLAT-1], not r[MEMLAT]
>>=20
>>  (4) I believe the address calcuation in .recovery3 and .recovery4 may
>>      also be off by 8; this is just based on eye-balling the code though,
>>      so I may be wrong
>>=20
>> Hope this helps,
>>=20
>>         --david
>>=20


----=20
Test case - run ~12 copies of this in parallel.

#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <time.h>

char *dest, *src;

void
sigill_handler(int sig)
{
        fprintf(stderr,"SIGILL: pid %d, dest 0x%lx, src 0x%lx\n",
                getpid(), (long)dest, (long)src);
        exit(1);
}

int
main() {
  time_t temp1;
  char *p, buffer[1024];

  signal(SIGILL, sigill_handler);
 =20
  time(&temp1);
  src =3D ctime(&temp1);

  dest =3D buffer;

  printf("%d\n", strlen(src));

  while(1)
      strncpy(buffer,src,strlen(src));
}


--=20
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com



--__--__--

Message: 4
Date: Thu, 04 Apr 2002 10:36:20 +0200
From: Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com>
Reply-To: francois-xavier_kowalski@hp.com
Organization: Hewlett-Packard
To: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)

David Mosberger wrote:

>>>>>>On Wed, 3 Apr 2002 23:29:58 +0200 (MEST), Erich Focht
<efocht@ess.nec.de> said:
>>>>>>
>
>  Erich> I've seen NaT consumption faults with an ISV application in a
>  Erich> loop involving speculative loads, too. It was very hard to
>  Erich> trace back (occured at different simulation times in a huge
>  Erich> case) and disappeared after we rewrote the loop and used the
>  Erich> latest Intel Fortran compiler. It occured with both B3 and C0
>  Erich> CPUs under 2.4.7 and 2.4.17. I don't have a testcase for
>  Erich> this, sorry.
>
>It's due to a glibc bug that was introduced last August when strncpy()
>was rewritten.  I sent a bug report (and preliminary patch) to the
>author and am waiting to hear back.
>

Do you have the bug-report ID on GNATS? I am not  able to find it in the=20
database to known if it is being worked-out by the maintainer.

FiX

--=20
Francois-Xavier "FiX" KOWALSKI





--__--__--

Message: 5
From: Andries.Brouwer@cwi.nl
Date: Thu, 4 Apr 2002 10:25:10 GMT
To: peterc@gelato.unsw.edu.au, util-linux@math.uio.no
Subject: Re: [util-linux] [Linux-ia64] mkswap.c ia64 fix  [patch]
Cc: linux-ia64@linuxia64.org, submit@bugs.debian.org

> mkswap fails to make large swap areas on IA64.  The patch is appended.

Thanks! Applied.
Andries


--__--__--

Message: 6
Date: Thu, 04 Apr 2002 19:29:46 +0900
From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
To: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)


 Hi there,

 I have a favor to ask David.
 If possible, plase give me the patch you had resolved
 this problem. I have been looking for the patch in all
 email(linux-ia64) but I could not find this patch.

 Thanks.

> David Mosberger took a look at the strncpy code & spotted
> the error:
>=20
> From David:
> >> I took a closer look and there seem to be several bugs in the routine:
> >>=20
> >>  (1) I don't think it's save to do:
> >>=20
> >>                 chk.s r[MEMLAT], .recovery3
> >>                 mov value =3D r[MEMLAT]
> >>=20
> >>      in the same cycle.  In the patch below, I fixed this by adding a
> >>      stop bit, but obviously it would be better to avoid that (either
> >>      by re-ordering the code or by adding a pipeline stage).
> >>=20
> >>  (2) stop bit was missing after br.cloop.dptk
> >>=20
> >>  (3) off-by-one error in .recovery4 code: the destination should be
> >>      r[MEMLAT-1], not r[MEMLAT]
> >>=20
> >>  (4) I believe the address calcuation in .recovery3 and .recovery4 may
> >>      also be off by 8; this is just based on eye-balling the code
though,
> >>      so I may be wrong
> >>=20
> >> Hope this helps,
> >>=20
> >>         --david
> >>=20
>=20
>=20
> ----=20
> Test case - run ~12 copies of this in parallel.
>=20
> #include <stdio.h>
> #include <signal.h>
> #include <string.h>
> #include <time.h>
>=20
> char *dest, *src;
>=20
> void
> sigill_handler(int sig)
> {
>         fprintf(stderr,"SIGILL: pid %d, dest 0x%lx, src 0x%lx\n",
>                 getpid(), (long)dest, (long)src);
>         exit(1);
> }
>=20
> int
> main() {
>   time_t temp1;
>   char *p, buffer[1024];
>=20
>   signal(SIGILL, sigill_handler);
>  =20
>   time(&temp1);
>   src =3D ctime(&temp1);
>=20
>   dest =3D buffer;
>=20
>   printf("%d\n", strlen(src));
>=20
>   while(1)
>       strncpy(buffer,src,strlen(src));
> }
>=20
>=20
> --=20
> Thanks
>=20
> Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20


--__--__--

Message: 7
From: =3D?windows-1252?Q?Anders Herbj=F8rnsen?<anders.herbjornsen@start.no>
To: linux-ia64@linuxia64.org
Date: Thu, 04 Apr 2002 13:48:50 +0200
Subject: [Linux-ia64] pipe() not setting errno.

Hello,

When running out of file descriptors pipe() does return -1 but
errno is not set. This is working ok on IA32 systems, but fails
on IA64. I've tested this with kernels 2.4.9 and 2.4.18.

Below is a small sample program to illustrate the problem:

########################################################
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

int main (int argc, char **argv){
  int i;
  for (i =3D 0; i < 3000; i++) {
    int fd[2];
    if (-1 =3D pipe(fd))
      break;
    printf ("%d ", i);
  } /* for */
  printf ("\npipe number %d error: errno=3D%d\n", i, errno);
  return errno;
}
#############################################################

Sample run:

$ ulimit -n 12
$ ./tpipe
0 1 2 3
pipe number 4 error: errno=3D0

Regards
Anders Herbj=F8rnsen





--__--__--

Message: 8
To: Anders =3D?iso-8859-1?q?Herbj=F8rnsen?=3D <anders.herbjornsen@start.no>
Cc: linux-ia64@linuxia64.org, libc-alpha@sources.redhat.com
Subject: Re: [Linux-ia64] pipe() not setting errno.
From: Andreas Schwab <schwab@suse.de>
Date: Thu, 04 Apr 2002 15:36:29 +0200

Anders Herbj=F8rnsen <anders.herbjornsen@start.no> writes:

|> Hello,
|>=20
|> When running out of file descriptors pipe() does return -1 but
|> errno is not set. This is working ok on IA32 systems, but fails
|> on IA64. I've tested this with kernels 2.4.9 and 2.4.18.

It's a bug in glibc, this should fix it:

2002-04-04  Andreas Schwab  <schwab@suse.de>

	* sysdeps/unix/sysv/linux/ia64/pipe.S: Don't overwrite r8 on
	error.

--- sysdeps/unix/sysv/linux/ia64/pipe.S.~1.2.~	2001-07-16
10:45:29.000000000 +0200
+++ sysdeps/unix/sysv/linux/ia64/pipe.S	2002-04-04 14:35:31.000000000 +0200
@@ -1,4 +1,4 @@
-/* Copyright (C) 1999, 2000 Free Software Foundation, Inc.
+/* Copyright (C) 1999, 2000, 2002 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
    Contributed by David Mosberger <davidm@hpl.hp.com>
=20
@@ -28,7 +28,7 @@
        cmp.ne p6,p0=3D-1,r10
        ;;
 (p6)   st4 [r2]=3Dr8,4
-       mov ret0=3D0
+(p6)   mov ret0=3D0
        ;;
 (p6)   st4 [r2]=3Dr9
 (p6)   ret

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."


--__--__--

Message: 9
From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 4 Apr 2002 07:54:57 -0800
To: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Reply-To: davidm@hpl.hp.com

>>>>> On Thu, 04 Apr 2002 19:29:46 +0900, "Hideki Yamamoto"
<hideki@hpc.bs1.fc.nec.co.jp> said:

  Hideki>  I have a favor to ask David.  If possible, plase give me
  Hideki> the patch you had resolved this problem. I have been looking
  Hideki> for the patch in all email(linux-ia64) but I could not find
  Hideki> this patch.

Jack just sent the patch.  Caveat: it has not been tested much.  You
may be better off reverting to the pre-August 2001 version of
strncpy() if stability is what you want.

	--david


--__--__--

Message: 10
From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 4 Apr 2002 10:44:31 -0800
To: francois-xavier_kowalski@hp.com
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Reply-To: davidm@hpl.hp.com

>>>>> On Thu, 04 Apr 2002 10:36:20 +0200, Francois-Xavier Kowalski
<francois-xavier_kowalski@hp.com> said:

  Francois-Xavier> Do you have the bug-report ID on GNATS? I am not
  Francois-Xavier> able to find it in the database to known if it is
  Francois-Xavier> being worked-out by the maintainer.

No, I don't.  I just reported it to Jakub Jelenik.

	--david


--__--__--

Message: 11
Date: Thu, 4 Apr 2002 21:27:58 +0200 (MEST)
From: Erich Focht <focht@ess.nec.de>
To: davidm@hpl.hp.com
cc: Jack Steiner <steiner@sgi.com>, linux-ia64@linuxia64.org,
        "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)

On Wed, 3 Apr 2002, David Mosberger wrote:

> It's due to a glibc bug that was introduced last August when strncpy()
> was rewritten.  I sent a bug report (and preliminary patch) to the
> author and am waiting to hear back.

The error I've seen didn't have anything to do with strncpy(), the loop
where the strange SIGILL and "NaT consumption" came from was:

      DO 502 IB=3D1,NBCUT0
      if(IB.GT.NBNCST.AND.IB.LE.NBNCEN) GO TO 502
      IP1=3DLCU(1,IB)
      IP2=3DLCU(2,IB)
      IF(LQ(1,IP1).LT.-NBC.OR.LQ(1,IP2).LT.-NBC) GO TO 502
      IDP1=3DNDIR(ICU(1,IB))
      LQ(IDP1,IP1)=3DLCB(1,IB)
      IDP2=3DNDIR(ICU(2,IB))
      LQ(IDP2,IP2)=3DLCB(2,IB)
  502 CONTINUE

You shouldn't blame me for the first IF condition, it's a third party
(ISV) code. The assembler code produced by the Fortran compiler looked
correct.

What change did you make for strncpy()? Did it somehow produce a NaT
somewhere where it could influence a Fortran program? I'd like to
understand whether the problem comes from a strange combination of
instructions or somehow propagates from glibc. Splitting the loop and
eliminating the first IF helped in this case, so it's improbable that
strncpy() is related to this.

Thanks,
best regards,
Erich




--__--__--

Message: 12
From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 4 Apr 2002 11:31:43 -0800
To: Erich Focht <focht@ess.nec.de>
Cc: davidm@hpl.hp.com, Jack Steiner <steiner@sgi.com>,
        linux-ia64@linuxia64.org, "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Reply-To: davidm@hpl.hp.com

>>>>> On Thu, 4 Apr 2002 21:27:58 +0200 (MEST), Erich Focht
<focht@ess.nec.de> said:

  Erich> What change did you make for strncpy()? Did it somehow
  Erich> produce a NaT somewhere where it could influence a Fortran
  Erich> program? I'd like to understand whether the problem comes
  Erich> from a strange combination of instructions or somehow
  Erich> propagates from glibc.

The glibc routine simply was buggy.  Garbage in, garbage out, not
surprise here.  I suspect your Fortran problem is something entirely
different.

	--david



--__--__--

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


End of Linux-IA64 Digest

