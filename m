From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Fri, 22 Jan 2010 22:19:41 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001221419h526d7301q340d0ec5d9fad345@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2010/1/18 =C9meric Maschino <emeric.maschino@gmail.com>:
> f1a2a9b6189f9f5c27672d4d32fec9492c6486b2 is the first bad commit
> commit f1a2a9b6189f9f5c27672d4d32fec9492c6486b2
> Author: David Miller <davem@davemloft.net>
> Date: =A0 Wed Feb 18 15:41:02 2009 -0800
>
> =A0 =A0drm: Preserve SHMLBA bits in hash key for _DRM_SHM mappings.
>
> =A0 =A0Platforms such as sparc64 have D-cache aliasing issues. =A0We
> =A0 =A0cannot allow virtual mappings in different contexts to be such
> =A0 =A0that two cache lines can be loaded for the same backing data.
> =A0 =A0Updates to one cache line won't be seen by accesses to the other
> =A0 =A0cache line.
>
> =A0 =A0Code in sparc64 and other architectures solve this problem by
> =A0 =A0making sure that all userland mappings of MAP_SHARED objects have
> =A0 =A0the same virtual address base. =A0They implement this by keying
> =A0 =A0off of the page offset, and using that to choose a suitably
> =A0 =A0consistent virtual address for mmap() requests.
>
> =A0 =A0Making things even worse, getting this wrong on sparc64 can result
> =A0 =A0in hangs during DRM lock acquisition. =A0This is because, at least=
 on
> =A0 =A0UltraSPARC-III, normal loads consult the D-cache but atomics such
> =A0 =A0as 'cas' (which is what cmpxchg() is implement using) only consult
> =A0 =A0the L2 cache. =A0So if a D-cache alias is inserted, the load can
> =A0 =A0see different data than the atomic, and we'll loop forever because
> =A0 =A0the atomic compare-and-exchange will never complete successfully.
>
> =A0 =A0So to make this all work properly, we need to make sure that the
> =A0 =A0hash address computed by drm_map_handle() preserves the SHMLBA
> =A0 =A0relevant bits, and that's what this patch does for _DRM_SHM mappin=
gs.
>
> =A0 =A0As a historical note, many years ago this bug didn't exist because=
 we
> =A0 =A0used to just use the low 32-bits of the address as the hash and ju=
st
> =A0 =A0hope for the best. =A0This preserved the SHMLBA bits properly. =A0=
But when
> =A0 =A0the hashtab code was added to DRM, this was no longer the case.
>
> =A0 =A0Signed-off-by: David S. Miller <davem@davemloft.net>
> =A0 =A0Signed-off-by: Dave Airlie <airlied@redhat.com>
>
> :040000 040000 ee229f793d981e8991d34826e0ddbc18e4cd9531
> f39f75d780bbb1bab844a755886ae81601d9fac5 M =A0 =A0 =A0drivers

Simply reverting commit f1a2a9b6189f9f5c27672d4d32fec9492c6486b2 from
kernel 2.6.33-rc4 makes the problem go away. But I bet this is not the
right way to fix it ;-)

Is there something else I can try?

=C9meric
