From: Matthew Wilcox <willy@debian.org>
Date: Mon, 29 Dec 2003 22:34:41 +0000
Subject: Re: GL-related crash w/ X 4.3 & kernel 2.6
Message-Id: <marc-linux-ia64-107273731805501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107272704926812@msgid-missing>
In-Reply-To: <marc-linux-ia64-107272704926812@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Mon, Dec 29, 2003 at 01:40:12PM -0800, David Mosberger wrote:
> I just tried DRI with a radeon 7000 again and am still getting the
> same old error message when inserting the radeon kernel module:
>=20
> [drm] Initialized radeon 1.9.0 20020828 on minor 0
> [drm:radeon_cp_init] *ERROR* radeon_cp_init called without lock held
> [drm:radeon_unlock] *ERROR* Process 968 using kernel context 0
>=20
> This is the same error message I saw on an x86 machine with a radeon
> chip.  I don't think AGP is available after this error message, so
> something must be different in your setup.  Can you confirm that you
> didn't get the same kind of drm error when loading radeon.ko?

I have it built-in rather than modular, but yes, I get:

Linux agpgart interface v0.100 (c) Dave Jones
agpgart: HP ZX1 IOC: IOPDIR shared with sba_iommu
agpgart: Maximum main memory to use for agp memory: 3861M
agpgart: AGP aperture is 512M @ 0x60000000
agpgart: Detected HP ZX1 HWP0003 AGP chipset (ioc=FEd01000, lba=FEd20000)
[drm] Initialized radeon 1.9.0 20020828 on minor 0
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled

Though while I'm looking at dmesg, I also see:

agpgart: Putting AGP V2 device at 0000:00:00.0 into 1x mode

I should look into that.

--=20
"Next the statesmen will invent cheap lies, putting the blame upon=20
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince=20
himself that the war is just, and will thank God for the better sleep=20
he enjoys after this process of grotesque self-deception." -- Mark Twain
