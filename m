From: Markus Schaber <markus.schaber@student.uni-ulm.de>
Date: Wed, 26 Mar 2003 18:14:18 +0000
Subject: Re: [parisc-linux] Re: [Linux-ia64] Linux, Itanium and PA/RISC
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=.nV7S4cEMG3SL7/"
Message-Id: <marc-linux-ia64-105590723705328@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705314@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705314@msgid-missing>
To: linux-ia64@vger.kernel.org

--=.nV7S4cEMG3SL7/
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

"Adriano Galano" <adriano@satec.es> schrieb:

> > [...] maybe one can even run a PA-RISC OS inside a virtual
> > PA-RISC Machine on Itaniums. (However I don't know any such VM.)
> Which VM are ported to Linux IA64? Bochs? Virtuozzo? VMWare? Plex86?
> Recent Microsoft adquisition
> (http://www.connectix.com/fr/about/acquisition_faq.html) is focus in
> this sense I think.

As far as I know, all those VMs emulate IA32 and not PA-RISC. So I don't
know how this could help in running a PA-RISC OS on an Itanium.

However, Bochs should be easy to port to another platform due to it's
pure interpreter nature. I don't know about Virtuozzo, but VMWare and
Plex86 run at least user-level app code natively, so they have to be
adopted to the IA64 Kern and the mode switching, I think. E. G. VMware
and Plex86 both make use of Kernel Modules / Patches which must be
adopted.

Gru=DF,
Markus

--=20
Schabi's Flohmarkt: http://schabi.de/flohmarkt/

Der Dienstweg ist die Verbindung der Sackgasse mit dem Holzweg!
[DoLi in unibwm.studium]

--=.nV7S4cEMG3SL7/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+ge3+6IhVmcufrl4RAv6wAJsG/0qP6/frhjZa/Ov3m5E/hLWXswCfY/xT
JK/ISNGxELj34jEe9xa3xJU=
=efH9
-----END PGP SIGNATURE-----

--=.nV7S4cEMG3SL7/--

