From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Thu, 11 Dec 2014 15:11:26 +0000
Subject: Re: Rebuilding a kernel for a proprietary closed-source ia64 module: possible or not?
Message-Id: <CAA9xbM48W+LYmiwdMvhdWb2jSPzX16ABeUdzRx=0hgj1ApuWoA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
In-Reply-To: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Sorry for the late reply, was out of town the passed days.

> And CONFIG_MODVERSIONS=3Dn is your solution to running proprietary
> modules without their recompilation on a different kernel.

No go if the kABI has evolved. You can even rebuild a "fake" kernel
with a totally different version but nevertheless naming it with what
the module was targeted for or forcing CONFIG_MODVERSIONS=3Dy, but
sooner or later (quite sooner!), you'll get kernel panics, hard locks
and/or other unwanted reboots ;-)

     =C3=89meric
