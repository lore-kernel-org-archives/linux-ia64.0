From: Mike Rapoport <rppt@kernel.org>
Date: Tue, 01 Dec 2020 10:29:01 +0000
Subject: Re: [PATCH v2 00/13] arch, mm: deprecate DISCONTIGMEM
Message-Id: <20201201102901.GF557259@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201101170454.9567-1-rppt@kernel.org>
 <43c53597-6267-bdc2-a975-0aab5daa0d37@physik.fu-berlin.de>
 <20201117062316.GB370813@kernel.org>
 <a7d01146-77f9-d363-af99-af3aee3789b4@physik.fu-berlin.de>
In-Reply-To: <a7d01146-77f9-d363-af99-af3aee3789b4@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Meelis Roos <mroos@linux.ee>, Michael Schmitz <schmitzmic@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will@kernel.org>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-snps-arc@lists.infradead.org

Hi Adrian,

On Tue, Dec 01, 2020 at 10:10:56AM +0100, John Paul Adrian Glaubitz wrote:
> Hi Mike!
> 
> On 11/17/20 7:23 AM, Mike Rapoport wrote:
> >> Apologies for the late reply. Is this still relevant for testing?
> >>
> >> I have already successfully tested v1 of the patch set, shall I test v2?
> > 
> > There were minor differences only for m68k between the versions. I've
> > verified them on ARAnyM but if you have a real machine a run there would
> > be nice.
> 
> I have just built a fresh kernel from the tip of Linus' tree and it boots
> fine on my RX-2600:
> 
> root@glendronach:~# uname -a
> Linux glendronach 5.10.0-rc6 #6 SMP Tue Dec 1 04:52:49 CET 2020 ia64 GNU/Linux
> root@glendronach:~#
> 
> No issues observed so far. Looking at the git log, it seems these changes haven't
> been merged for 5.10 yet. I assume they will be coming with 5.11?

These changes are in linux-mm tree (https://www.ozlabs.org/~akpm/mmotm/
with a mirror at https://github.com/hnaz/linux-mm)

I beleive they will be coming in 5.11.

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
