From: Florian Weimer <fw@deneb.enyo.de>
Date: Fri, 17 Mar 2023 22:55:59 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <87y1nvng1s.fsf@mid.deneb.enyo.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
In-Reply-To: <20230215100008.2565237-1-ardb@kernel.org> (Ard Biesheuvel's
        message of "Wed, 15 Feb 2023 11:00:03 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

* Ard Biesheuvel:

> The IA64 port of Linux has no maintainer, and according to a report from
> its only remaining user [0], it has been broken for a month and nobody
> cares.
>
> Given that keeping a complex but unused architecture alive uses up
> valuable developer bandwidth, let's just get rid of it.
>
> This supersedes my patch proposing to mark it as 'dead', which received
> no replies from anyone that wants to keep it alive. [1]

Is this still going ahead?

In userspace, ia64 is of course full of special cases, too, so many of
us really want to see it gone, but we can't really start the removal
process while there is still kernel support.
