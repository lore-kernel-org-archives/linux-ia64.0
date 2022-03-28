From: Jakub Kicinski <kuba@kernel.org>
Date: Mon, 28 Mar 2022 20:20:14 +0000
Subject: Re: [PATCH 00/22] Replace comments with C99 initializers
Message-Id: <20220328132014.6b8c0a21@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
        <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz>
        <87fsn2zaix.fsf@kernel.org>
        <cc104272-d79a-41e1-f4de-cb78fb073991@stuerz.xyz>
In-Reply-To: <cc104272-d79a-41e1-f4de-cb78fb073991@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?UTF-8?B?U3TDvHJ6?= <benni@stuerz.xyz>
Cc: Kalle Valo <kvalo@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

On Mon, 28 Mar 2022 13:51:42 +0200 Benjamin St=C3=BCrz wrote:
> > Just a small tip: If you are new, start with something small and learn
> > from that. Don't do a controversial big patchset spanning multiple
> > subsystems, that's the hard way to learn things. First submit one patch
> > at a time to one subsystem and gain understanding of the process that
> > way.
>=20
> I actually thought this would be such simple thing. Do you know of any
> good thing where to start? I already looked into drivers/staging/*/TODO
> and didn't found something for me personally.

FWIW on the netdev side there's work coming to convert a set of features
from unsigned long to a BITMAP which will require converting a lot of
drivers to an explicit helpers from direct access.

https://lore.kernel.org/all/20220324154932.17557-14-shenjian15@huawei.com/

If it seems interesting enough you can try reaching out to Jian Shen.
