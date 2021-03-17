From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 17 Mar 2021 17:28:31 +0000
Subject: Re: [PATCH] hpsa: fix boot on ia64 (atomic_t alignment)
Message-Id: <23674602-0f14-0b71-3192-aa0184a34d6e@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <5532f9ab-7555-d51b-f4d5-f9b72a61f248@redhat.com>
 <20210312222718.4117508-1-slyfox@gentoo.org>
In-Reply-To: <20210312222718.4117508-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, storagedev@microchip.com, linux-scsi@vger.kernel.org, Joe Szczypek <jszczype@redhat.com>, Scott Benesh <scott.benesh@microchip.com>, Scott Teel <scott.teel@microchip.com>, Tomas Henzl <thenzl@redhat.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Don Brace <don.brace@microchip.com>

Hi Sergei!

On 3/12/21 11:27 PM, Sergei Trofimovich wrote:
> The failure initially observed as boot failure on rx3600 ia64 machine
> with RAID bus controller: Hewlett-Packard Company Smart Array P600:
> 
>     kernel unaligned access to 0xe000000105dd8b95, ip=0xa000000100b87551
>     kernel unaligned access to 0xe000000105dd8e95, ip=0xa000000100b87551
>     hpsa 0000:14:01.0: Controller reports max supported commands of 0 Using 16 instead. Ensure that firmware is up to date.
>     swapper/0[1]: error during unaligned kernel access
> 
> Here unaligned access comes from 'struct CommandList' that happens
> to be packed. The change f749d8b7a ("scsi: hpsa: Correct dev cmds
> outstanding for retried cmds") introduced unexpected padding and
> un-aligned atomic_t from natural alignment to something else.
> 
> This change does not remove packing annotation from struct but only
> restores alignment of atomic variable.
> 
> The change is tested on the same rx3600 machine.

I just gave it a try on my RX2660 and for me, the hpsa driver won't load even
with your patch.

Can you share your kernel configuration so I can give it a try?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
