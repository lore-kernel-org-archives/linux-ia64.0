From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 17 Mar 2021 13:19:23 +0000
Subject: RE: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <4b2a64d91c4c478f881d9713cac5001b@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
        <20210312222718.4117508-1-slyfox@gentoo.org>
        <SN6PR11MB2848561E3D85A8F55EB86977E16B9@SN6PR11MB2848.namprd11.prod.outlook.com>
        <CAK8P3a3JYmhbN3TXB2cWGfXGKgsUa9Hg=ZvWckTaL_31OMgbtQ@mail.gmail.com>
 <yq1zgz21rkz.fsf@ca-mkp.ca.oracle.com>
In-Reply-To: <yq1zgz21rkz.fsf@ca-mkp.ca.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Martin K. Petersen'" <martin.petersen@oracle.com>, Arnd Bergmann <arnd@kernel.org>
Cc: "Don.Brace@microchip.com" <Don.Brace@microchip.com>, Sergei Trofimovich <slyfox@gentoo.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "storagedev@microchip.com" <storagedev@microchip.com>, linux-scsi <linux-scsi@vger.kernel.org>, "jszczype@redhat.com" <jszczype@redhat.com>, "Scott.Benesh@microchip.com" <Scott.Benesh@microchip.com>, "Scott.Teel@microchip.com" <Scott.Teel@microchip.com>, "thenzl@redhat.com" <thenzl@redhat.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>

From: Martin K. Petersen 
> Sent: 17 March 2021 02:26
> 
> Arnd,
> 
> > Actually that still feels wrong: the annotation of the struct is to
> > pack every member, which causes the access to be done in byte units on
> > architectures that do not have hardware unaligned load/store
> > instructions, at least for things like atomic_read() that does not go
> > through a cmpxchg() or ll/sc cycle.
> 
> > This change may fix itanium, but it's still not correct. Other
> > architectures would have already been broken before the recent change,
> > but that's not a reason against fixing them now.
> 
> I agree. I understand why there are restrictions on fields consumed by
> the hardware. But for fields internal to the driver the packing doesn't
> make sense to me.

Jeepers -- that global #pragma pack(1) is bollocks.

I think there are a couple of __u64 that are 32bit aligned.
Just marking those field __packed __aligned(4) should have
the desired effect.
Or use a typedef for '__u64 with 32bit alignment'.
(There probably ought to be one in types.h)

Then add compile-time asserts that any non-trivial structures
the hardware accesses are the right size.

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
