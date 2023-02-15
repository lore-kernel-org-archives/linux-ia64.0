From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 15 Feb 2023 10:17:11 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <534469b750e1847e1645f9ae5ed19dcc80b82be6.camel@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>, linux-kernel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

Hello Ard!

On Wed, 2023-02-15 at 11:00 +0100, Ard Biesheuvel wrote:
> The IA64 port of Linux has no maintainer, and according to a report from
> its only remaining user [0], it has been broken for a month and nobody
> cares.

It's not that I don't care. I just haven't been able to bisect the bug .yet

> Given that keeping a complex but unused architecture alive uses up
> valuable developer bandwidth, let's just get rid of it.
> 
> This supersedes my patch proposing to mark it as 'dead', which received
> no replies from anyone that wants to keep it alive. [1]

I'm actually fine with marking it as dead. I forgot to ack.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
