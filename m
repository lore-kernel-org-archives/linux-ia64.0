From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 30 Mar 2004 11:39:20 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <40695C68.4A5F551E@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org> <1080321646.31638.105.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Dave Hansen wrote:
>=20
> Have you considered any common ground your patch might share with the
> people doing memory hotplug?
>=20
>         http://people.valinux.co.jp/~iwamoto/mh.html
>=20
> They have a similar problem to your migration that occurs when a user
> wants to remove a whole or partial NUMA node.
> lhms-devel@lists.sourceforge.net

Comparing my stuff to their work, I just do some small performance enhancem=
ents:

- I do not modify a single line on the existing VM paths - if my stuff has =
no
  improvement for you, then yo will not be obliged to pay any overhead
- I do not insist on :-)) ... that would block the execution of the applica=
tion
  while the resources are not available
- I handle only the simplest case: private anonymous pages (...a singe PTE.=
..)

- IWAMOTO Toshihiro provides a complete "fool proof" solution with obligati=
on to
  cussed in the migration

> Is your code something that you'd like to see go into the mainline 2.6
> or 2.7 kernel?

Since someone is asking...

Thanks,

Zolt=E1n
