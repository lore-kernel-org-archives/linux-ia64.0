From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 29 Mar 2021 14:22:35 +0000
Subject: Re: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <CAK8P3a15jo_qup0W4itY2Fkm=SZ-NuQjmUTpDBPigSCvrF_+Yg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
 <20210312222718.4117508-1-slyfox@gentoo.org> <SN6PR11MB2848C136F6CB4EA66D42FFAEE1639@SN6PR11MB2848.namprd11.prod.outlook.com>
 <ea49071d-d1e1-97b7-6468-501be0b9b195@physik.fu-berlin.de>
In-Reply-To: <ea49071d-d1e1-97b7-6468-501be0b9b195@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Don.Brace@microchip.com, Sergei Trofimovich <slyfox@gentoo.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi <linux-scsi@vger.kernel.org>, jszczype@redhat.com, Scott.Benesh@microchip.com, Scott.Teel@microchip.com, thenzl@redhat.com, "Martin K. Petersen" <martin.petersen@oracle.com>

On Mon, Mar 29, 2021 at 1:28 PM John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
> On 3/24/21 7:37 PM, Don.Brace@microchip.com wrote:
> >
> > Acked-by: Don Brace <don.brace@microchip.com>
> >
> > Thanks for your patch and extra effort.
>
> Apologies for being so persistent, but has this patch been queued anywhere?
>
> This should be included for 5.12 if possible as it unbreaks the kernel on alot
> of Itanium servers (and potentially other machines with the HPSA controller).
>
> If no one wants to pick the patch up, it could go through Andrew Morton's tree (-mm).
>

I think Martin is still waiting for a fixed version of the patch, as
the proposed patch from
March 12 only solves the immediate symptom, but not the underlying problem
of the CommandList structure being marked as unaligned. If it gets fixed, the
new version should work on all architectures.

         Arnd
