From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 13 Oct 2003 20:55:16 +0000
Subject: Re: [PATCH] select EFI partition support by default
Message-Id: <marc-linux-ia64-106607858723703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106588409310269@msgid-missing>
In-Reply-To: <marc-linux-ia64-106588409310269@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> "John" =3D John Levon <levon@movementarian.org> writes:

John> On Mon, Oct 13, 2003 at 10:00:47AM +0100, Christoph Hellwig
John> wrote:
>> > > +=A0=A0=A0=A0=A0=A0 bool "EFI GUID Partition support" if PARTITION_A=
DVANCED
>> > > +=A0=A0=A0=A0=A0=A0 default y if !PARTITION_ADVANCED && IA64
>> >=20
>> > Can we make CONFIG_LBD force on CONFIG_EFI_PARTITION too then?
>>=20
>> I know the LBD backport is used with SGI disklabels in production
>> enviroments.  In fact that's the only production use I know of at
>> all...

John> Besides, unless I'm missing something, current 2.6 doesn't
John> prompt for LBD for IA64 at all ?

John> So, anybody want the patch :)

There's no need to prompt for CONFIG_LBD in 2.6, as all 64-bit
architectures use  64-bit variables for sector_t.

It's only on 32-bit architectures that it's necessary.

Under 2.4, however, CONFIG_LBD is (or should be) forced on for IA64.

Peterc
