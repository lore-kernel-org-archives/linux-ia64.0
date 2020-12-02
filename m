From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 02 Dec 2020 08:46:42 +0000
Subject: Re: [PATCH v2 00/13] arch, mm: deprecate DISCONTIGMEM
Message-Id: <20201202084642.GA28110@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <a7d01146-77f9-d363-af99-af3aee3789b4@physik.fu-berlin.de>
 <20201201102901.GF557259@kernel.org>
 <e3d5d791-8e4f-afcc-944c-24f66f329bd7@physik.fu-berlin.de>
 <20201201121033.GG557259@kernel.org>
 <49a2022c-f106-55ec-9390-41307a056517@physik.fu-berlin.de>
 <20201201135623.GA751215@kernel.org>
 <59351dbb-96cc-93b2-f2ec-b8968e935845@kernel.dk>
 <CAMuHMdWRc8W7U0LKyH9u1hdMuN515PCZiTEJ12FrDaCx-eTdaQ@mail.gmail.com>
 <20201202084326.GA26573@infradead.org>
 <efc13ee8-ec6c-a807-d866-99f72a94e3f5@physik.fu-berlin.de>
In-Reply-To: <efc13ee8-ec6c-a807-d866-99f72a94e3f5@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Christoph Hellwig <hch@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux MM <linux-mm@kvack.org>, Will Deacon <will@kernel.org>, Greg Ungerer <gerg@linux-m68k.org>, Jonathan Corbet <corbet@lwn.net>, Meelis Roos <mroos@linux.ee>, Russell King <linux@armlinux.org.uk>, Mike Rapoport <rppt@linux.ibm.com>, Matt Turner <mattst88@gmail.com>, arcml <linux-snps-arc@lists.infradead.org>, Alexey Dobriyan <adobriyan@gmail.com>, Michael Schmitz <schmitzmic@gmail.com>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Jens Axboe <axboe@kernel.dk>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, alpha <linux-alpha@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@kernel.org>

On Wed, Dec 02, 2020 at 09:45:24AM +0100, John Paul Adrian Glaubitz wrote:
> > I've never got results.  Which is annoying, as debian doesn't ship an
> > ia64 cross toolchain either, and I can't find any pre-built one that
> > works for me.
> 
> The ia64 toolchain available from kernel.org works for me for cross-building
> a kernel that boots on my RX2600.
> 
> It's just not a fully-fledged toolchain due to the limitations with libunwind.

Actually, you are right, I did manage to finally get that working a
while ago.  I think openrisc is the one where I failed to get anything
to work at all now that I think of it.
