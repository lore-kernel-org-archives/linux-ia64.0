From: Bruno Cornec <Bruno.Cornec@hp.com>
Date: Thu, 24 Jul 2003 12:30:51 +0000
Subject: Re: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105904997430316@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox (willy@debian.org) said:

> it's true on other architectures too, not just ia64. =20

Well in general yes, but at least on i386 (I can't test on something else)
doing cat /proc/kcore doesn't crash the system. And BTW why should it ?
There is nothing wrong with it (for ex. I used it a lot of times to try
to find a BIOS revision on i386).

I just wonder if this could be used as a DOS from outside the system. In
which case, it would be a Bad Thing (tm :-)

> root can crash
> the system any way they want. =20

Yes, that's true. But it just more surprising when you think you just
pass a normal command ;-)

> stupid user syndrome; they should be
> using -xdev to not tar up /proc.

Yes, of course, I again agree with you.=20
But even if I don't do that myself, I tried on a rx5670 the cat /proc/kcore
in the past, with the same result, for valid (IMHO) reasons and was really
surprised to see the system rebooting. BTW, it also underline the inability
for Oracle 9iRAC to fail over properly, which was also a surprise :-)

Every time I see a program doing "core dumped" even if I pass to it crazy
args, I tend to believe it's not good enough, and can hide other problems.
It's a bug for me, not a feature.
And again in that precise case, I'm far from being able to provide patch.
Just grumbling ;-)

Bruno.
--=20
Linux Solution Consultant         T=E9l: +33 476 143 278 - Fax: +33 476 146=
 105
HP/Intel Solution Center http://hpintelco.net Hewlett-Packard Grenoble/Fran=
ce
Des infos sur Linux?  http://www.HyPer-Linux.org      http://www.hp.com/lin=
ux
La musique ancienne?  http://www.musique-ancienne.org http://www.medieval.o=
rg
