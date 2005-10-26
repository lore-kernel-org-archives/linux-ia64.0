From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 26 Oct 2005 20:25:56 +0000
Subject: Re: [PATCH] kexec on ia64
Message-Id: <m1irvkvxd7.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

>> Cool.  Tony, what are your plans for pushing this to Linus?  Will it make 
>> 2.6.15?
>
> Nanhai Zou here at Intel expressed a few concerns to me last night
> about Khalid's patch.  I'll paste them here to speed discussion about
> this (as I expect Nanhai is asleep at the moment, he should be
> around to start commenting for himself by 4-5pm Pacific).
>
>> I think his patch is still not able to boot an unmodified kernel.
>> It appends a kernel parameter to bypass the issue, thus the second kernel need
> to be modified.
>
>> It also hardcoded initrd logic in kernel patch.
>> Command line is still using old command line.
>> No purgatory code support etc.

I agree that is an issue that should be addressed.
It would be nice if there was a kernel option to not virtually
map EFI.  Reusing a supplied virtual address is also good, but
it means we can't boot an unpatched kernel.

>> How, I prefer to put a small and clean patch in kernel while leave most of the
> things in kexec-tools.
>> That will provide more flexibility.
>
>> There are also some other issues I can see, like, 
>> 1. icache flusing miss
>> 2. rendez code is fake, I prefer to use hotplug API.
>> 3. Disable PCI master code should be in generic PCI driver code instead of
> IA64 arch code.
>
> Nanhai has his own patches for kexec/kexec-tools, which are
> stuck in some Intel bureaucracy at the moment ...  I'm trying
> to get them unstuck so that we can get some meaningful
> commentary from the community about both versions.
>
> My biggest issue with both patches at the moment is that I
> can't see how either of them can be extended to be useful
> for use in crash-dump case without some significant surgery.
> Both of them over-write the existing kernel with the new one,
> which is a big problem when you'd like to dump the data space
> of the old kernel.  Ia64 is quite happy to run a kernel loaded
> at any suitably aligned address ... so why not load the new
> kernel in some different location from the old kernel?

Interesting.  This should be a decision made by kexec-tools,
not by the kernel.  On x86 the kernel just verifies we load the
crash kernel into the reserved chunk of the address space.  I haven't
looked closely enough to see if the architecture part has fixed
address assumptions yet.  

Tony what were you seeing that made you conclude that the code
would always load over the existing kernel?

I also didn't see the trivial patch to put the 32bit compat support
in.  It's not terribly important or useful but there is no reason
not to include it.

Eric
