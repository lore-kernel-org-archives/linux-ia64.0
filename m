From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 07 Aug 2009 22:06:10 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1prb7nust.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A7A3A78.7080200@redhat.com> <m1y6pxr737.fsf@fess.ebiederm.org>
	<4A7A506B.2060008@redhat.com> <m1ljlxsiox.fsf@fess.ebiederm.org>
	<4A7A70E5.2010204@redhat.com> <m1bpmtqxjh.fsf@fess.ebiederm.org>
	<4A7A7A0F.6070906@redhat.com> <m1iqh1nxv3.fsf@fess.ebiederm.org>
	<4A7A9E54.60705@redhat.com> <m1iqgze740.fsf@fess.ebiederm.org>
	<20090807210306.GA25609@basil.fritz.box>
In-Reply-To: <20090807210306.GA25609@basil.fritz.box> (Andi Kleen's message of "Fri\, 7 Aug 2009 23\:03\:06 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: Amerigo Wang <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Bernhard Walle <bernhard.walle@gmx.de>, Kexec Mailing List <kexec@lists.infradead.org>

Andi Kleen <andi@firstfloor.org> writes:

>> As an initial approximation I would use a 32nd of low memory.
>
> That means a 1TB machine will have a 32GB crash kernel.
>
> Surely that's excessive?!?
>
> It would be repeating all the same mistakes people made with hash tables
> several years ago.
>
>> 
>> That can be written to (with enough privileges when no crash kernel is
>> loaded) reduce the amount of memory reserved by the crash kernel.
>> 
>> Bernhard does that sound useful to you?
>> 
>> Amerigo does that seem reasonable?
>
> It doesn't sound reasonable to Andi.
>
> Why do you even want to grow the crash kernel that much? Is there
> any real problem with a 64-128MB crash kernel?

Because it is absolutely ridiculous in size and user space will have
to take up the work of trimming back down to something reasonable in
the init script.

At a practical level crash dump userlands do things like fsck
filesystems before they mount them.  For truly large machines there
was a desire to parallelize core dump writing to different disks.  I
don't know if that has been implemented yet, but in that case you
certainly more ram for buffers tends to be useful.

I think if we are going to go beyond having a magic boot command
line (that we have today) that parametrizes the amount of memory
to reserve based on how much memory we have in the system.  We need
to put user space in control.  We can only put user space in control
if we initially reserve too much and let it release the memory it
won't use.

That would allow removing magic from installers and leaving it to 
installed packages.  Which seems a lot more maintainable. 

Eric
