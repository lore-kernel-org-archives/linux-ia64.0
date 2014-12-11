From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 11 Dec 2014 15:16:37 +0000
Subject: Re: Rebuilding a kernel for a proprietary closed-source ia64 module: possible or not?
Message-Id: <CAA9xbM6ruXTwM=9QfYmzqXnKG1Vy9MxHhqezhs8EKpKts-hQzg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
In-Reply-To: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi again,

> Isn't it a /src/linux-rtgfx-2.6.5-7.244-obj/ia64/rtgfx/.config
> from the kernel-rtgfx-source-2.6.5-7.244.ia64.rpm?

I'm indeed talking about fglrx, but not the one in SLES.
So don't know how was the kernel that created it configured.

BTW, I've also tried to rebuild the SLES rtgfx kernel, but changing
from SN2 to ZX1. Same problem as previously posted: function hex
signatures differ while I'm however using the same kernel tree, but
with a different configuration.

     =C3=89meric
