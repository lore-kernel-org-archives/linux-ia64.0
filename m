From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 08 Feb 2007 23:45:18 +0000
Subject: RE: Zero size /proc/vmcore on ia64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BE3@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070205015901.GA31446@verge.net.au>
In-Reply-To: <20070205015901.GA31446@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2007=C4=EA2=D4=C28=C8=D5 21:08
> To: Zou, Nanhai
> Cc: vgoyal@in.ibm.com; fastboot; Linux-IA64; Luck, Tony
> Subject: Re: Zero size /proc/vmcore on ia64
>=20
> On Thu, Feb 08, 2007 at 03:52:15PM +0800, Zou, Nanhai wrote:
> >
> >   Those values are wrong,
> > Could you test we a 2.6.20 plus the patch?
>=20
> I tried 2.6.20 + your patch.
> I tried the same with the addition of Bob Picco's patch to stop
> the crash-kernel crashing.
> And I tried with Sparse and Discontig memory.
> And in all cases I get much the same result :(
>=20
> I'm wondering if perhaps its got something to do with kexec-tools,
> I'm using kexec-tools-testing from git. Is there any possibility
> you could send a static binary the version that you are using
> (if its from Eric's old tree cross compiling doesn't really work)?
>=20
> Or perhaps my kernel config is odd.
>=20
> > Also it will be helpful to print efi_memmap in purgatory code.
>=20
> Indeed. Do you have any way to dump purgatory's console across
> a serial port? The vga console and I are on opposite sides of town
> at the moent.
>=20
 I have not implement serial print in purgatory code yet, see comments in p=
urgatory/arch/ia64/console-ia64.c
 However from your print, I can see last 2 entries of efi mem map are corru=
pt.=20
So we need to find out if it purgatory code who corrupted them or something=
 else overlapped with that 2 entries.

 Thanks
 Zou Nan hai
>=20
> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
