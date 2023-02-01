From: Helge Deller <deller@gmx.de>
Date: Wed, 01 Feb 2023 08:21:03 +0000
Subject: Re: [RFC][PATCHSET] VM_FAULT_RETRY fixes
Message-Id: <8f60f7d8-3e2f-2a91-c7a3-6a005d36d7d3@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y9lz6yk113LmC9SI@ZenIV>
 <CAHk-=whf73Vm2U3jyTva95ihZzefQbThZZxqZuKAF-Xjwq=G4Q@mail.gmail.com>
 <Y9mD1qp/6zm+jOME@ZenIV>
 <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
In-Reply-To: <CAHk-=wjiwFzEGd_60H3nbgVB=R_8KTcfUJmXy=hSXCvLrXQRFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Peter Xu <peterx@redhat.com>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, sparclinux@vger.kernel.org

On 1/31/23 22:19, Linus Torvalds wrote:
> On Tue, Jan 31, 2023 at 1:10 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> Umm...  What about the semantics of get_user() of unmapped address?
>> Some architectures do quiet EFAULT; some (including alpha) hit
>> the sucker with SIGBUS, no matter what.
>
> I think we should strive to just make this all common.
>
> The reason alpha is different is almost certainly not intentional, but
> a combination of "pure accident" and "nobody actually cares".
>
>> Are we free to modify that behaviour, or is that part of arch-specific
>> ABI?
>
> I'd just unify this all, probably with a preference for existing
> semantics on x86 (because of "biggest and most varied user base").
>
> That whole "send SIGBUS even for kernel faults" is certainly bogus and
> against the usual rules. And I may well be to blame for it (I have
> this memory of disliking how EFAULT as a return code didn't actually
> return the faulting address). And realistically, it's also just not
> something that any normal application will ever hit.  Giving invalid
> addresses to system calls is basically always a bug, although there
> are always special software that do all the crazy corner cases (ie
> things like emulators tend to do odd things).
>
> I doubt such special software exists on Linux/alpha, though.
>
> So I wouldn't worry about those kinds of oddities overmuch.
>
> *If* somebody then finds a load that cares, we can always fix it
> later, and I'll go "mea culpa, I didn't think it would matter, and I
> was wrong".

AFAICS, the only applications which really care about the return
code are
- testsuites like LTP (i.e. the fstat05 testcase)
- some (not just debian) packages execute tests at the end of the
   build process and verify the return codes, i.e. libsigsegv.

The differences between the architectures is currently often taken care
of via #ifdefs, so if the return code is harmonized across platforms
it would at least help to simplify such testcases.

Helge
