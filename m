From: Helge Deller <deller@gmx.de>
Date: Thu, 18 Jun 2020 20:51:37 +0000
Subject: Re: rename probe_kernel_* and probe_user_*
Message-Id: <7b3da127-6101-045e-9a8a-4d46198c1190@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200617073755.8068-1-hch@lst.de>
 <CAHk-=wjpnu=882iD9ck9Ywt6R1LYX_Hv-oS7dBMsWZwDRGZ5jA@mail.gmail.com>
In-Reply-To: <CAHk-=wjpnu=882iD9ck9Ywt6R1LYX_Hv-oS7dBMsWZwDRGZ5jA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, the arch/x86 maintainers <x86@kernel.org>

On 18.06.20 21:48, Linus Torvalds wrote:
> [ Explicitly added architecture lists and developers to the cc to make
> this more visible ]
>
> On Wed, Jun 17, 2020 at 12:38 AM Christoph Hellwig <hch@lst.de> wrote:
>>
>> Andrew and I decided to drop the patches implementing your suggested
>> rename of the probe_kernel_* and probe_user_* helpers from -mm as there
>> were way to many conflicts.  After -rc1 might be a good time for this as
>> all the conflicts are resolved now.
>
> So I've merged this renaming now, together with my changes to make
> 'get_kernel_nofault()' look and act a lot more like 'get_user()'.
>
> It just felt wrong (and potentially dangerous) to me to have a
> 'get_kernel_nofault()' naming that implied semantics that we're all
> familiar with from 'get_user()', but acting very differently.
>
> But part of the fixups I made for the type checking are for
> architectures where I didn't even compile-test the end result. I
> looked at every case individually, and the patch looks sane, but I
> could have screwed something up.
>
> Basically, 'get_kernel_nofault()' doesn't do the same automagic type
> munging from the pointer to the target that 'get_user()' does, but at
> least now it checks that the types are superficially compatible.
> There should be build failures if they aren't, but I hopefully fixed
> everything up properly for all architectures.
>
> This email is partly to ask people to double-check, but partly just as
> a heads-up so that _if_ I screwed something up, you'll have the
> background and it won't take you by surprise.

Linus. thanks for the heads-up!
With your change it compiles cleanly on 32- and 64-bit parisc.

Helge
