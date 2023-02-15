From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Feb 2023 19:30:50 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <CAHk-=wjEmZ19T4XpVb0_Hacm53xJG_w5ygcuorwC0xBoT-myUA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org> <534469b750e1847e1645f9ae5ed19dcc80b82be6.camel@physik.fu-berlin.de>
In-Reply-To: <534469b750e1847e1645f9ae5ed19dcc80b82be6.camel@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: Ard Biesheuvel <ardb@kernel.org>, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, linux-ia64@vger.kernel.org

On Wed, Feb 15, 2023 at 2:17 AM John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> It's not that I don't care. I just haven't been able to bisect the bug .yet

I'm not a fan of ia64 as an architecture, but it's a bit sad to remove
it entirely. It's not like it's been a huge maintenance burden in
general.

That said, if it doesn't work, and nobody has the time and/or
inclination to figure out why, I don't really see any alternative.

             Linus
