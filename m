From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 15 Feb 2023 23:09:10 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <f896bde517ac65e1933bba4f2ceb9f4a9717e7bd.camel@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
         <534469b750e1847e1645f9ae5ed19dcc80b82be6.camel@physik.fu-berlin.de>
         <CAHk-=wjEmZ19T4XpVb0_Hacm53xJG_w5ygcuorwC0xBoT-myUA@mail.gmail.com>
In-Reply-To: <CAHk-=wjEmZ19T4XpVb0_Hacm53xJG_w5ygcuorwC0xBoT-myUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ard Biesheuvel <ardb@kernel.org>, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, linux-ia64@vger.kernel.org

Hi Linus!

On Wed, 2023-02-15 at 11:30 -0800, Linus Torvalds wrote:
> On Wed, Feb 15, 2023 at 2:17 AM John Paul Adrian Glaubitz
> <glaubitz@physik.fu-berlin.de> wrote:
> > 
> > It's not that I don't care. I just haven't been able to bisect the bug .yet
> 
> I'm not a fan of ia64 as an architecture, but it's a bit sad to remove
> it entirely. It's not like it's been a huge maintenance burden in
> general.

I agree. It would be sad to see it go.

> That said, if it doesn't work, and nobody has the time and/or
> inclination to figure out why, I don't really see any alternative.

That's not really what I meant though. I definitely have the time to look
after the architecture as I am also maintaining it in Debian.

What I meant here is that I simply hadn't had the time yet to fully debug
this particular regression that was introduced with 6.1. I did actually
start a bisect and got close to the problematic commit as I got distracted
with my day job.

My plan was definitely to continue debugging the problem in the coming weekend
and at least find the commit that introduced the regression. I always have an
Itanium server ready for testing kernels that I can power on and control remotely
via its built-in management system.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
