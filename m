From: "Martin K. Petersen" <martin.petersen@oracle.com>
Date: Tue, 30 Mar 2021 03:02:26 +0000
Subject: Re: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <yq1wntpgxxr.fsf@ca-mkp.ca.oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
        <20210312222718.4117508-1-slyfox@gentoo.org>
        <SN6PR11MB2848C136F6CB4EA66D42FFAEE1639@SN6PR11MB2848.namprd11.prod.outlook.com>
        <ea49071d-d1e1-97b7-6468-501be0b9b195@physik.fu-berlin.de>
        <CAK8P3a15jo_qup0W4itY2Fkm=SZ-NuQjmUTpDBPigSCvrF_+Yg@mail.gmail.com>
In-Reply-To: <CAK8P3a15jo_qup0W4itY2Fkm=SZ-NuQjmUTpDBPigSCvrF_+Yg@mail.gmail.com>
        (Arnd Bergmann's message of "Mon, 29 Mar 2021 16:22:35 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Don.Brace@microchip.com, Sergei Trofimovich <slyfox@gentoo.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi <linux-scsi@vger.kernel.org>, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, thenzl@redhat.com, "Martin K. Petersen" <martin.petersen@oracle.com>


Arnd,

> I think Martin is still waiting for a fixed version of the patch, as
> the proposed patch from March 12 only solves the immediate symptom,
> but not the underlying problem of the CommandList structure being
> marked as unaligned. If it gets fixed, the new version should work on
> all architectures.

Yep.

I unfortunately don't have any hpsa adapters to test with. Was hoping
somebody with hardware would attempt to fix up the struct properly.

Given -rc5 we're running out of time so for 5.12 it's probably best if
we queue up the workaround. I would prefer an amalgamation of Don's and
Sergei's patches, though. I do like the assert so we can catch problems
early.

But really, somebody should fix this. While hpsa may be out of
commercial support, Linux will support the driver it until there are no
more users. And the current structure packing is just wrong.

-- 
Martin K. Petersen	Oracle Linux Engineering
