From: =?ISO-8859-1?Q?=C9meric_Maschino?= <emeric.maschino@gmail.com>
Date: Mon, 18 Jan 2010 15:44:22 +0000
Subject: Re: [drm:drm_mmap_locked] *ERROR* Could not find map: Could this be
Message-Id: <d72eeaf61001180744l5599afb7m5de23e29d633817d@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
In-Reply-To: <d72eeaf61001041440s58b51b9j58e62af378b55224@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

2010/1/14 =C9meric Maschino <emeric.maschino@gmail.com>:
> 2010/1/14 Dave Airlie <airlied@redhat.com>:
>> If I had to guess I'd go with
>>
>> b674137755bbe2750f997a2a1264db3cdf8abcb3
>>
>> But maybe a bisect would be more definite.
>
> OK, git bisect pending.

git bisect complete. Here's the result:

f1a2a9b6189f9f5c27672d4d32fec9492c6486b2 is the first bad commit
commit f1a2a9b6189f9f5c27672d4d32fec9492c6486b2
Author: David Miller <davem@davemloft.net>
Date:   Wed Feb 18 15:41:02 2009 -0800

    drm: Preserve SHMLBA bits in hash key for _DRM_SHM mappings.

    Platforms such as sparc64 have D-cache aliasing issues.  We
    cannot allow virtual mappings in different contexts to be such
    that two cache lines can be loaded for the same backing data.
    Updates to one cache line won't be seen by accesses to the other
    cache line.

    Code in sparc64 and other architectures solve this problem by
    making sure that all userland mappings of MAP_SHARED objects have
    the same virtual address base.  They implement this by keying
    off of the page offset, and using that to choose a suitably
    consistent virtual address for mmap() requests.

    Making things even worse, getting this wrong on sparc64 can result
    in hangs during DRM lock acquisition.  This is because, at least on
    UltraSPARC-III, normal loads consult the D-cache but atomics such
    as 'cas' (which is what cmpxchg() is implement using) only consult
    the L2 cache.  So if a D-cache alias is inserted, the load can
    see different data than the atomic, and we'll loop forever because
    the atomic compare-and-exchange will never complete successfully.

    So to make this all work properly, we need to make sure that the
    hash address computed by drm_map_handle() preserves the SHMLBA
    relevant bits, and that's what this patch does for _DRM_SHM mappings.

    As a historical note, many years ago this bug didn't exist because we
    used to just use the low 32-bits of the address as the hash and just
    hope for the best.  This preserved the SHMLBA bits properly.  But when
    the hashtab code was added to DRM, this was no longer the case.

    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Dave Airlie <airlied@redhat.com>

:040000 040000 ee229f793d981e8991d34826e0ddbc18e4cd9531
f39f75d780bbb1bab844a755886ae81601d9fac5 M	drivers

And here are the diffs:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff;h=F1a2a9b6189f9f5c27672d4d32fec9492c6486b2

Should I try to simply revert this patch and see if the "interesting
behaviour" is gone? Will it work with actual 2.6.33 kernel
architecture?

=C9meric
