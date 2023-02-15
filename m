From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 15 Feb 2023 23:13:44 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <77ff2776d99286eac6eefecb1903b96899d0ff62.camel@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
         <534469b750e1847e1645f9ae5ed19dcc80b82be6.camel@physik.fu-berlin.de>
         <CAHk-=wjEmZ19T4XpVb0_Hacm53xJG_w5ygcuorwC0xBoT-myUA@mail.gmail.com>
         <SJ1PR11MB6083F7F30FE9ED8F39FA1F85FCA39@SJ1PR11MB6083.namprd11.prod.outlook.com>
         <CAHk-=wj9RkLN+GpYcFmsd8tze6zYL7MMkNpvdKbETQnqYm+Hwg@mail.gmail.com>
In-Reply-To: <CAHk-=wj9RkLN+GpYcFmsd8tze6zYL7MMkNpvdKbETQnqYm+Hwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Jessica Clarke <jrtc27@jrtc27.com>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Wed, 2023-02-15 at 12:08 -0800, Linus Torvalds wrote:
> But when it's actively known to be broken and nobody has time or
> interest to look at it, at that point the "it doesn't look any more
> painful than other architectures" becomes kind of moot.

Let me look after it in the weekend and let's see whether we can unbreak
it. I don't think there is really a big issue. The last time we had a
similar issue was the regression introduced by 974b9b2c68f3 which got fixed
with the simple fix in bd05220c7be3.

It's probably similarly trivial to fix the current regression.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
