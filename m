From: Horms <horms@verge.net.au>
Date: Tue, 27 Jun 2006 07:25:26 +0000
Subject: Re: [PATCH] ia64, kexec: shutting down the PCI devices does not seem to be neccessary
Message-Id: <20060627072524.GA26185@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060627071600.GA25965@verge.net.au>
In-Reply-To: <20060627071600.GA25965@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, Jun 27, 2006 at 04:16:02PM +0900, Horms wrote:
> As suggested by Nanhai Zou, it seems that the pci shutdown code in kdump
> is not neccessary. I tested the patch on a Tiger2 box, and it seems
> to work fine.

I should point out that this patch (inadvertantly) removes the irq-end
magic that you were doing in order to make the MPT Fusion function after
reboot. However, that device came up just fine with this patch applied.
I wonder if a recent fix to MPT is helping us.

http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
it;h=9Bf0a28c9a24e2cee5deecf89d118254374c75ba

--=20
Horms                                          =20
H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/en/

