From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 Jun 2002 17:34:42 +0000
Subject: Re: [Linux-ia64] Back to the future: which gcc for kernel 2.4.18 ?
Message-Id: <marc-linux-ia64-105590701905643@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905641@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905641@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 5 Jun 2002 17:28:54 +0200 (DFT), Xavier Bru  <Xavier.Bru@bull=
.net> said:

  Xavier> Building kernel 2.4.18 for ia64 with gcc version 2.96
  Xavier> 20000731 , it seems that there is some problem with code
  Xavier> generation in the ia64_log_rec_header_print() routine that
  Xavier> prints MCA informations: year appears to be 18002 :-)

  Xavier> Looking at the code with gdb, it seems that the generated
  Xavier> code uses the f6 register without ininitializing: ...
  Xavier> 0xe0000000044351f1 <ia64_log_rec_header_print+337>: xmpy.l
  Xavier> f6=F6,f7 ...

Yes, I just tried with gcc 2.96 and I see this too: f6 is used twice
without being initialized anywhere in the routine.

  Xavier> I tried using gcc3 (gcc version 3.0.2 20010905), but I get
  Xavier> an internal compiler error when I build the kernel.

Haven't tried 3.0.2, but gcc3.1 compiles the code fine and without the
"f6-bug" (but this may be just luck, because gcc3.1 doesn't use xma at
all for this routine).

Can you narrow down the bug and report it to the gcc folks?  It would
be good to know that gcc3.1 really gets it right (and doesn't just get
lucky).

	--david

