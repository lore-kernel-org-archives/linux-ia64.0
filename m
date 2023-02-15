From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 15 Feb 2023 12:46:38 +0000
Subject: Re: [RFC PATCH 2/5] kernel: Drop IA64 support from sig_fault handlers
Message-Id: <51900fc5-1a5c-4414-a85b-061a0cd58c63@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230215100008.2565237-1-ardb@kernel.org>
 <20230215100008.2565237-3-ardb@kernel.org>
 <ea12dd12-db17-44a8-8c29-6b0a129f355d@app.fastmail.com>
 <62e7ab37-1148-4cf1-8d6a-3da440fa623f@app.fastmail.com>
 <CAMj1kXGYcLLaJQfYjcjvAnFbb+MAWQF-2BzeUGJTqBu4V=ejNw@mail.gmail.com>
In-Reply-To: <CAMj1kXGYcLLaJQfYjcjvAnFbb+MAWQF-2BzeUGJTqBu4V=ejNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ardb@kernel.org>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Matthew Wilcox <willy@infradead.org>, Marc Zyngier <maz@kernel.org>, Guenter Roeck <linux@roeck-us.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org

On Wed, Feb 15, 2023, at 12:22, Ard Biesheuvel wrote:
> On Wed, 15 Feb 2023 at 12:15, Arnd Bergmann <arnd@arndb.de> wrote:
>>
>> CONFIG_IA64
>> CONFIG_IA64_PAGE_SIZE_64KB
>> CONFIG_IA64_SGI_UV
>> CONFIG_IA64_DEBUG_CMPXCHG
>> CONFIG_MSPEC
>
> These are all gone from the code after applying this series.

Ok, got it. I missed that the first patch also removes
bits outside of arch/ia64.

     Arnd
