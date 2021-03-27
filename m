From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sat, 27 Mar 2021 10:24:33 +0000
Subject: Re: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <20210327102433.179ce571@sf>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
        <20210312222718.4117508-1-slyfox@gentoo.org>
        <23674602-0f14-0b71-3192-aa0184a34d6e@physik.fu-berlin.de>
In-Reply-To: <23674602-0f14-0b71-3192-aa0184a34d6e@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi@vger.kernel.org, Joe Szczypek <jszczype@redhat.com>, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, Tomas Henzl <thenzl@redhat.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Don Brace <don.brace@microchip.com>

On Wed, 17 Mar 2021 18:28:31 +0100
John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:

> Hi Sergei!
> 
> On 3/12/21 11:27 PM, Sergei Trofimovich wrote:
> > The failure initially observed as boot failure on rx3600 ia64 machine
> > with RAID bus controller: Hewlett-Packard Company Smart Array P600:
> > 
> >     kernel unaligned access to 0xe000000105dd8b95, ip=0xa000000100b87551
> >     kernel unaligned access to 0xe000000105dd8e95, ip=0xa000000100b87551
> >     hpsa 0000:14:01.0: Controller reports max supported commands of 0 Using 16 instead. Ensure that firmware is up to date.
> >     swapper/0[1]: error during unaligned kernel access
> > 
> > Here unaligned access comes from 'struct CommandList' that happens
> > to be packed. The change f749d8b7a ("scsi: hpsa: Correct dev cmds
> > outstanding for retried cmds") introduced unexpected padding and
> > un-aligned atomic_t from natural alignment to something else.
> > 
> > This change does not remove packing annotation from struct but only
> > restores alignment of atomic variable.
> > 
> > The change is tested on the same rx3600 machine.  
> 
> I just gave it a try on my RX2660 and for me, the hpsa driver won't load even
> with your patch.
> 
> Can you share your kernel configuration so I can give it a try?

Sure! Here is a config from a few days ago:
    https://dev.gentoo.org/~slyfox/configs/guppy-config-5.12.0-rc4-00016-g427684abc9fd-dirty

-- 

  Sergei
