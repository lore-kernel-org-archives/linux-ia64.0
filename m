From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 08 Apr 2004 16:23:43 +0000
Subject: Re: syscall_linkage
Message-Id: <20040408162342.GA21914@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <407575C0.840593AC@nospam.org>
In-Reply-To: <407575C0.840593AC@nospam.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

On Thu, Apr 08, 2004 at 05:54:40PM +0200, Zoltan Menyhart wrote:
> Can somebody explain me, please, what the difference is between an
> __attribute__((syscall_linkage)) call and a regular one ?
>=20

It indicates to the compiler that the arguments of the function=20
are to be treated read-only. If they need to be modified, then a
copy is made into  other registers. This is necessary for the=20
system call entry points because some syscalls can be restarted
and they need to restart we the orginal values. Remember that
all syscall arguments are passed in registers AND the registers
come straight from the user level, i.e., they are never copied.


> The Itanium Software Conventions & Runtime Architecture Guide does
> not say a word about it, does it mean it is a non standard way to
> pass parameters ?
>=20
> What registers need / do not need to be saved with respect to what
> is written in the Intel book ?
>=20
> Thanks,
>=20
> Zolt=E1n Menyh=E1rt
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20

-Stephane
