From: Mike Rapoport <rppt@kernel.org>
Date: Wed, 02 Dec 2020 07:14:27 +0000
Subject: Re: [PATCH v2 00/13] arch, mm: deprecate DISCONTIGMEM
Message-Id: <20201202071427.GD751215@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <43c53597-6267-bdc2-a975-0aab5daa0d37@physik.fu-berlin.de>
 <20201117062316.GB370813@kernel.org>
 <a7d01146-77f9-d363-af99-af3aee3789b4@physik.fu-berlin.de>
 <20201201102901.GF557259@kernel.org>
 <e3d5d791-8e4f-afcc-944c-24f66f329bd7@physik.fu-berlin.de>
 <20201201121033.GG557259@kernel.org>
 <49a2022c-f106-55ec-9390-41307a056517@physik.fu-berlin.de>
 <20201201135623.GA751215@kernel.org>
 <4c752ff0-27a6-b9d7-ab81-8aac1a3b7b65@physik.fu-berlin.de>
 <ea5bae0e-9f27-355f-d841-cf8b362b0b70@physik.fu-berlin.de>
In-Reply-To: <ea5bae0e-9f27-355f-d841-cf8b362b0b70@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Meelis Roos <mroos@linux.ee>, Michael Schmitz <schmitzmic@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-snps-arc@lists.infradead.org, Jens Axboe <axboe@kernel.dk>

Hi Adrian,

On Tue, Dec 01, 2020 at 08:55:37PM +0100, John Paul Adrian Glaubitz wrote:
> Hi Mike!
> 
> On 12/1/20 4:07 PM, John Paul Adrian Glaubitz wrote:
> > This fixes the issue for me.
> > 
> > Tested-by: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> 
> I just booted the kernel from the linux-mm branch and I can't get the hpsa driver
> to work anymore. Even if I compile it into the kernel, the driver is no longer
> loaded and hence I can't access the disks.
> 
> Any idea what could be wrong?

I know nearly nothing about SCSI, I can only suggest to enable all the
debug options available and see if anything shows up :)

> Adrian
> 
> -- 
>  .''`.  John Paul Adrian Glaubitz
> : :' :  Debian Developer - glaubitz@debian.org
> `. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
>   `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
> 
> 

-- 
Sincerely yours,
Mike.
