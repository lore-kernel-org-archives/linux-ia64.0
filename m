From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 28 Jul 2000 14:52:13 +0000
Subject: Re: [Linux-ia64] Cross compiling problem: relocation truncated to fit ...
Message-Id: <marc-linux-ia64-105590678205240@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205239@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205239@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Did you try the -relax option?  If your linker still isn't able to
build a big binary with that option specified, you need a newer
linker.  I do have a prebuilt version for NUE, but it will use
different paths from your own cross environment.

	--david

>>>>> On Fri, 28 Jul 2000 10:06:06 +0200, "Nuesser, Wilhelm" <wilhelm.nuess=
er@sap.com> said:

  Willi> Hi, when cross compiling ia64 exec=B4s on an ia32 the cross-ld
  Willi> states
=09
  Willi> /usr/cross/lib/gcc-lib/ia64-gnu-linux-gnu/2.9-ia64-000216-final/cr=
tbegin.o(.
  Willi> fini+0x2): relocation truncated to fit: PCREL21B fini This is
  Willi> reproduceable. When making the same - admittedly quite huge -
  Willi> exec on an ia64 natively the make works fine.

  Willi> Any ideas? Just a stupid setup problem?

  Willi> Thanks in advance

  Willi> Willi

  Willi> ------------------ Willi N=FC=DFer SAP LinuxLab
  Willi> wilhelm.nuesser@sap.com


  Willi> _______________________________________________ Linux-IA64
  Willi> mailing list Linux-IA64@linuxia64.org
  Willi> http://lists.linuxia64.org/lists/listinfo/linux-ia64


