From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 26 Feb 2003 18:34:43 +0000
Subject: Re: [Linux-ia64] [HELP] Implementing TCP request on EFI
Message-Id: <marc-linux-ia64-105590709805931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805930@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805930@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Naim,

On Wed, Feb 26, 2003 at 09:50:08AM +0100, Na=EFm Jonathan wrote:
> What is the best method to implement socket on EFI? With only Gnu-Efi
> and not intel toolkit... Because in protocol single network there is
> only UDP request with IP and the function transmit anly take MAC
> adresses as parameter....
>=20
The gnu-efi toolkit provides a minimal library which implements
only the core EFI interface (as defined by the EFI specification).

The TCPIP support is part of the toolkit which is a set of libraries
and commands built on top of the basic EFI functionalities.

At this point we do not have a port of the toolkit to Linux/ia64
and the GNU tools.

--=20
-Stephane

