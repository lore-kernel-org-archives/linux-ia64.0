From: matoro <matoro_mailinglist_kernel@matoro.tk>
Date: Fri, 19 May 2023 20:56:36 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <5e778e16f93f2286fa535597ba5da24b@matoro.tk>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On 2023-05-19 16:17, Frank Scheiner wrote:
> Dear matoro, Florian,
> 
> On 17.05.23 23:47, matoro wrote:
>> On 2023-05-17 15:39, Florian Weimer wrote:
>>> * Frank Scheiner:
>>> 
>>>> On 12.05.23 17:57, Ard Biesheuvel wrote:
>>>>> The bottom line is that, while I know of at least 2 people (on cc)
>>>>> that test stuff on itanium, and package software for it, I don't 
>>>>> think
>>>>> there are any actual users remaining, and so it is doubtful whether 
>>>>> it
>>>>> is justified to ask people to spend time and effort on this.
>>>> 
>>>> While I get your argument, I also find it important to be able to
>>>> innovate without destroying the past. And with the already severly
>>>> limited choice of current architectures for the masses (x86, arm), 
>>>> it
>>>> becomes even more important to keep what we have or had in the past, 
>>>> to
>>>> not end in a "If all you have is a hammer, everything looks like a
>>>> nail." type of future.
>>> 
>>> The history doesn't go away.  We still have pre-built ia64 system
>>> images, the sources, and current machines can run ia64 code under
>>> QEMU.  Those host systems will remain available (maybe under
>>> virtualization) for many, many years to come.  So if anyone wants to
>>> experiment with an architecture that has register trap bits and 
>>> things
>>> like that, it's possible.
>>> 
>>> I expect the rest of the hardware itself is not remarkable, and
>>> anything useful has been thoroughly reused for other systems (like we
>>> did for the Itanium C++ ABI on the software side).
>>> 
>>> From the userspace side, the issue is not so much testing (if we
>>> bother to test our changes at all, we can use emulation), but
>>> half-completed implementaton work (I ran into missing relaxations in
>>> the link editor a while back, for example), and those limitations 
>>> have
>>> knock-on effects on generic code that we have to maintain.
>> 
>> FYI, QEMU does not have ia64 host or target support, not even TCG.
> 
> I assume Florian means user mode emulation, which for example can be 
> used to complete a `debootstrap --foreign [...]` run when you don't 
> have an existing ia64 userland on real hardware at hand.
> 
> I doubt that it works in the exact same way than the real thing, 
> though. Such differences are part of the reasons why the OpenBSD devs 
> don't seem to use cross compilers or virtualized or emulated systems to 
> produce and test their OS, though they seem to use cross compilers for 
> the bringup of new platforms IIC.
> 
> But if it's good enough to run ia64 binaries on other arches, why not.
> 
> Have a nice weekend,
> Frank

There is no user-mode emulation for ia64 in QEMU either.  The only 
"ongoing" emulation work is Sergei's fork of the old "ski" emulator, but 
this is far from QEMU quality or even usable yet:  
https://github.com/trofi/ski

Anyway, to summarize this thread for Ard:  the answer to the question of 
if anybody is using these machines for anything other than to 
experimentally see if things run or churn out packages is NO.  Any 
Itanium machines running useful production workloads are on HP-UX/VMS.  
Possibly Windows Server 2008 or an old RHEL, but unlikely.

The only argument for continued support is as you described, the 
argument from the commons, that the ecosystem as a whole benefits from 
diversity of architectures.  All that matters is whether you find this 
argument convincing.  There are some like myself who do, but I am not a 
kernel maintainer.  If you don't, then that should be that.
