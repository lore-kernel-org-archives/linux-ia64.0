From: Matthew Wilcox <matthew@wil.cx>
Date: Sat, 07 Oct 2006 08:43:23 +0000
Subject: Re: Compile errors for allmodconfig
Message-Id: <20061007084323.GW2563@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061006234259.GB14909@shell0.pdx.osdl.net>
In-Reply-To: <20061006234259.GB14909@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Fri, Oct 06, 2006 at 04:42:59PM -0700, Judith Lebzelter wrote:
> I am trying to get the alllmodconfig to build without errors for ia64 and=
 it is not=20
> happening because of a few drivers:
>=20
> WARNING: "check_signature" [drivers/scsi/fdomain.ko] undefined!

Hi Judith,

I've been looking at allmodconfig for parisc too, and have a fix for
this one.  It's these two commits:

http://git.parisc-linux.org/?p=3Dlinux-2.6.git;a=3Dcommitdiff;ht190f56ed272=
ef407020bce63d63d6858277699
http://git.parisc-linux.org/?p=3Dlinux-2.6.git;a=3Dcommitdiff;hO55d0a1ac479=
409fdd14de162e6496b9c9e585c

I sent them to Linus on Thursday, and he's ignored them so far.  If there
were some demand from other people, perhaps he'd look at them again ;-)

> WARNING: "pci_get_legacy_ide_irq" [drivers/ide/pci/amd74xx.ko] undefined!

I fixed this on parisc with this patch:

http://git.parisc-linux.org/?p=3Dlinux-2.6.git;a=3Dcommitdiff;h=F3120945566=
19aed849862089938c14aa6a5b84b
