From: Ard Biesheuvel <ardb@kernel.org>
Date: Wed, 15 Feb 2023 16:59:35 +0000
Subject: Re: [RFC PATCH 1/5] arch: Remove Itanium (IA-64) architecture
Message-Id: <CAMj1kXHpyBrSvRVk+SyOzxFuYEWiL1uOxtdya5gXW3nbO95K5g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org> <20230215100008.2565237-2-ardb@kernel.org>
 <20230215165832.GB3786546@roeck-us.net>
In-Reply-To: <20230215165832.GB3786546@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Wed, 15 Feb 2023 at 17:58, Guenter Roeck <linux@roeck-us.net> wrote:
>
> On Wed, Feb 15, 2023 at 11:00:04AM +0100, Ard Biesheuvel wrote:
> > Itanium is the original architecture for which EFI was developed, and
> > the way Linux supports it deviates significantly from other
> > architectures.
> >
> > So it is anyone's guess whether the ongoing maintenance and developement
> > of the EFI subsystem has regressed Itanium or not - QEMU no longer
> > implements support for it, and so there is zero test coverage using
> > actual hardware.
> >
> > Note that the Intel firmware team themselves already removed all IA-64
> > support from the Tianocore/EDK2 reference implementation of EFI in 2018,
> > so let's follow suit, and drop IA-64 from Linux as well.
> >
> > Acked-by: Tony Luck <tony.luck@intel.com>
> > Signed-off-by: Ard Biesheuvel <ardb@kernel.org>
>
> Trying again since the previous message bounced with "message too long".
>
> Acked-by: Guenter Roeck <linux@roeck-us.net>
>
> Sorry for the noise for anyone receiving this twice.
>

Thanks, and this is my fault really - I used the -D option to omit the
pre-images but the patch is still >100k :-(
