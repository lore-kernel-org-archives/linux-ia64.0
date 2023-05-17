From: matoro <matoro_mailinglist_kernel@matoro.tk>
Date: Wed, 17 May 2023 21:47:30 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <4e210d61adbe73a1673f113019401e5c@matoro.tk>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 2023-05-17 15:39, Florian Weimer wrote:
> * Frank Scheiner:
> 
>> On 12.05.23 17:57, Ard Biesheuvel wrote:
>>> The bottom line is that, while I know of at least 2 people (on cc)
>>> that test stuff on itanium, and package software for it, I don't 
>>> think
>>> there are any actual users remaining, and so it is doubtful whether 
>>> it
>>> is justified to ask people to spend time and effort on this.
>> 
>> While I get your argument, I also find it important to be able to
>> innovate without destroying the past. And with the already severly
>> limited choice of current architectures for the masses (x86, arm), it
>> becomes even more important to keep what we have or had in the past, 
>> to
>> not end in a "If all you have is a hammer, everything looks like a
>> nail." type of future.
> 
> The history doesn't go away.  We still have pre-built ia64 system
> images, the sources, and current machines can run ia64 code under
> QEMU.  Those host systems will remain available (maybe under
> virtualization) for many, many years to come.  So if anyone wants to
> experiment with an architecture that has register trap bits and things
> like that, it's possible.
> 
> I expect the rest of the hardware itself is not remarkable, and
> anything useful has been thoroughly reused for other systems (like we
> did for the Itanium C++ ABI on the software side).
> 
> From the userspace side, the issue is not so much testing (if we
> bother to test our changes at all, we can use emulation), but
> half-completed implementaton work (I ran into missing relaxations in
> the link editor a while back, for example), and those limitations have
> knock-on effects on generic code that we have to maintain.

FYI, QEMU does not have ia64 host or target support, not even TCG.
