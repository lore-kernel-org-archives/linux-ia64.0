From: Mike Rapoport <rppt@kernel.org>
Date: Thu, 16 Feb 2023 05:04:53 +0000
Subject: Re: [RFC PATCH 0/5] Retire IA64/Itanium support
Message-Id: <Y+25dZiA+xnZRgVX@kernel.org>
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, Arnd Bergmann <arnd@arndb.de>, Jessica Clarke <jrtc27@jrtc27.com>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Hi Linus,

On Wed, Feb 15, 2023 at 12:08:28PM -0800, Linus Torvalds wrote:
> On Wed, Feb 15, 2023 at 11:43 AM Luck, Tony <tony.luck@intel.com> wrote:
> >
> > Maybe you don't see others pain?  I added Al Viro ... perhaps
> > he'll replay some of his thoughts from trying to make signals
> > and other stuff work correctly on ia64.
> 
> Well, as long as it's ia64-specific, I'll just go "hey, it was Al's
> choice to look at that code".
> 
> IOW, I'm more worried about "ia64 makes it a pain to make _generic_ changes".
> 
> IOW, doing something like this:
> 
>     git log -p --no-merges --since=1.year arch/ia64/
> 
> to see what kind of pain ia64 parts of patches have caused, about a
> third of them are that "look, somebody cared about ia64 explicitly".
 
I remember that when I was doing cleanups of mm initialization, ia64
required special care several times.

> That said, it's entirely possible I've missed some particular painpoint.

The largest painpoint IMO is absence of any ability to test ia64 except
sending patches to Adrian in a hope he has time to give them a whirl.
 
>                   Linus

-- 
Sincerely yours,
Mike.
