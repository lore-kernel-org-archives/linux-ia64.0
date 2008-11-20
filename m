From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 20 Nov 2008 22:45:59 +0000
Subject: RE: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35C4BCF62@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> Well, then let's make it a boot option (or a sysctl). The default must
> be psr.ac =3D 1, but if the admin sees "unaligned access" messages and
> knows that there is no way of getting a (timely) fix for that particular
> production system, s/he should be able to turn them off.

Nice in theory ... but since the setting of psr.ac happens as an immediate
value in the instructions in all the trap handlers, this would require
yet another batch of kernel patching its own code ... which we do plenty
of already ... but I'm not feeling in the mood to add more for this.

I've been swayed by Rick's arguments ... we don't appear to have
much of a problem at the moment with kernel unaligned accesses, so
let's try to keep it that way.  I'm putting in a patch that turns
on psr.ac in head.S so we do strict aligment checking all the time
in the kernel.

-Tony
=FF=F4=E8=BA{.n=C7+=89=B7=9F=AE=89=AD=86+%=8A=CB=FF=B1=E9=DD=B6=17=A5=8Aw=
=FF=BA{.n=C7+=89=B7=A5=8A{=B1=FE&=BA=E3=F8=A7=B6=17=9B=A1=DC=A8}=A9=9E=B2=
=C6=A0z=DA&j:+v=89=A8=FE=F8=1E=AF=F9=1E=AEw=A5=FE=8A=E02=8A=DE=99=A8=E8=AD=
=DA&=A2)=DF=A1=ABa=B6=DA=FF=FF=FB=E0z=BF=E4z=B9=DE=97=FA+=83=F9=9A=8E=8A=DD=
=A2j=FF=8Aw=E8=FE=1Bf
