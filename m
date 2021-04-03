From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sat, 03 Apr 2021 14:51:48 +0000
Subject: Re: [PATCH v2 3/3] hpsa: add an assert to prevent from __packed reintroduction
Message-Id: <20210403155148.0f5c94ff@sf>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com>
        <20210330071958.3788214-1-slyfox@gentoo.org>
        <20210330071958.3788214-3-slyfox@gentoo.org>
        <CAK8P3a2CmQpKynwGbtdWH+1L4=SkX2y4XKggT=8DrnsjxU4hSw@mail.gmail.com>
        <TU4PR8401MB1055C76F16F4D8A2DCF541F8AB7A9@TU4PR8401MB1055.NAMPRD84.PROD.OUTLOOK.COM>
In-Reply-To: <TU4PR8401MB1055C76F16F4D8A2DCF541F8AB7A9@TU4PR8401MB1055.NAMPRD84.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Elliott, Robert (Servers)" <elliott@hpe.com>
Cc: Arnd Bergmann <arnd@kernel.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don Brace - C33706 <don.brace@microchip.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "storagedev@microchip.com" <storagedev@microchip.com>, linux-scsi <linux-scsi@vger.kernel.org>, "jszczype@redhat.com" <jszczype@redhat.com>, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, "thenzl@redhat.com" <thenzl@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 2 Apr 2021 14:40:39 +0000
"Elliott, Robert (Servers)" <elliott@hpe.com> wrote:

> It looks like ia64 implements atomic_t as a 64-bit value and expects atom=
ic_t
> to be 64-bit aligned, but does nothing to ensure that.
>=20
> For x86, atomic_t is a 32-bit value and atomic64_t is a 64-bit value, and
> the definition of atomic64_t is overridden in a way that ensures
> 64-bit (8 byte) alignment:
>=20
> Generic definitions are in include/linux/types.h:
>     typedef struct {
>             int counter;
>     } atomic_t;
>=20
>     #define ATOMIC_INIT(i) { (i) }
>=20
>     #ifdef CONFIG_64BIT
>     typedef struct {
>             s64 counter;
>     } atomic64_t;
>     #endif
>=20
> Override in arch/x86/include/asm/atomic64_32.h:
>     typedef struct {
>             s64 __aligned(8) counter;
>     } atomic64_t;
>=20
> Perhaps ia64 needs to take over the definition of both atomic_t and atomi=
c64_t
> and do the same?

I don't think it's needed. ia64 is a 64-bit arch with expected
natural alignment for s64: alignof(s64)=3D8.

Also if my understanding is correct adding __aligned(8) would not fix
use case of embedding locks into packed structs even on x86_64 (or i386):

    $ cat a.c
    #include <stdio.h>
    #include <stddef.h>

    typedef struct { unsigned long long __attribute__((aligned(8))) l; } lo=
ck_t;
    struct s { char c; lock_t lock; } __attribute__((packed));
    int main() { printf ("offsetof(struct s, lock) =3D %lu\nsizeof(struct s=
) =3D %lu\n", offsetof(struct s, lock), sizeof(struct s)); }

    $ x86_64-pc-linux-gnu-gcc a.c -o a && ./a
    offsetof(struct s, lock) =3D 1
    sizeof(struct s) =3D 9

    $ x86_64-pc-linux-gnu-gcc a.c -o a -m32 && ./a
    offsetof(struct s, lock) =3D 1
    sizeof(struct s) =3D 9

Note how alignment of 'lock' stays 1 byte in both cases.

8-byte alignment added for i386 in
    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=BBf2a330d92c5afccfd17592ba9ccd50f41cf748
is only as a performance optimization (not a correctness fix).

Larger alignment on i386 is preferred because alignof(s64)=3D4 on
that target which might make atomic op span cache lines that
leads to performance degradation.

--=20

  Sergei
