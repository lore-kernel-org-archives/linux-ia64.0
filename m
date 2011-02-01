From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 01 Feb 2011 19:46:46 +0000
Subject: RE: [RFC][PATCH] kmsg_dumper for NVRAM
Message-Id: <987664A83D2D224EAE907B061CE93D530194487CA2@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C1472ACC8@USINDEVS01.corp.hds.com>
 <20110201092942.GD21239@cr0.nay.redhat.com>
In-Reply-To: <20110201092942.GD21239@cr0.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: =?utf-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>, Seiji Aguchi <seiji.aguchi@hds.com>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "Yu, Fenghua" <fenghua.yu@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "arnd@arndb.de" <arnd@arndb.de>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, "shiyer@redhat.com" <shiyer@redhat.com>, "pjones@redhat.com" <pjones@redhat.com>, Satoru Moriya <satoru.moriya@hds.com>

> This looks like what Tony wanted, pstore.

Yes - this looks like another means to the same end (making console log
Available after a crash).

I wonder whether you could use my pstore file system interface
for this ... you'd need to write a backend that used EFI variable
space to save the pieces of a console log, in much the same way
that I used ERST to stash the pieces.

This might be a bit messy - but I think that it would be
worth doing in order to provide a single user interface
to the kmsg_dump on different architectures, regardless
of the underlying storage method used.  I.e. the OS
vendors would just have to write startup scripts to glean
information from /dev/pstore and clear it by removing the
files there. Rather than having one set of scripts that
looks at EFI variables for machines that use that, a different
set for machines that have the sparc64 method of saving in
some special area of ram, and yet another set for a machine
that has some other motherboard magical non volatile storage
that hasn't been designed yet.

-Tony

=FF=F4=E8=BA{.n=C7+=89=B7=9F=AE=89=AD=86+%=8A=CB=FF=B1=E9=DD=B6=17=A5=8Aw=
=FF=BA{.n=C7+=89=B7=A5=8A{=B1=FE&=BA=E3=F8=A7=B6=17=9B=A1=DC=A8}=A9=9E=B2=
=C6=A0z=DA&j:+v=89=A8=FE=F8=1E=AF=F9=1E=AEw=A5=FE=8A=E02=8A=DE=99=A8=E8=AD=
=DA&=A2)=DF=A1=ABa=B6=DA=FF=FF=FB=E0z=BF=E4z=B9=DE=97=FA+=83=F9=9A=8E=8A=DD=
=A2j=FF=8Aw=E8=FE=1Bf
