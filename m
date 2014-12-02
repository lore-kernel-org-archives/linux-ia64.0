From: Alex <lausgans@gmail.com>
Date: Tue, 02 Dec 2014 10:32:01 +0000
Subject: Re: Rebuilding a kernel for a proprietary closed-source ia64 module: possible or not?
Message-Id: <loom.20141202T111602-74@post.gmane.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
In-Reply-To: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> Hi,

Hi, =C3=89meric

> I'm however missing the original kernel
> configuration

Isn't it a /src/linux-rtgfx-2.6.5-7.244-obj/ia64/rtgfx/.config
from the kernel-rtgfx-source-2.6.5-7.244.ia64.rpm?

Please note that it's for sgi machines, not hp ones:
# CONFIG_IA64_HP_ZX1 is not set
CONFIG_IA64_SGI_SN2=3Dy
So it's not usable as is

