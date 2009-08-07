From: Bernhard Walle <bernhard.walle@gmx.de>
Date: Fri, 07 Aug 2009 21:26:09 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7C9BF1.8070700@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A7A3A78.7080200@redhat.com> <m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com> <m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com> <m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com> <m1iqh1nxv3.fsf@fess.ebiederm.org> <4A7A9E54.60705@redhat.com> <m1iqgze740.fsf@fess.ebiederm.org> <20090807210306.GA25609@basil.fritz.box>
In-Reply-To: <20090807210306.GA25609@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Amerigo Wang <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Kexec Mailing List <kexec@lists.infradead.org>

Andi Kleen schrieb:
>> As an initial approximation I would use a 32nd of low memory.
> 
> That means a 1TB machine will have a 32GB crash kernel.
> 
> Surely that's excessive?!?
> 
> It would be repeating all the same mistakes people made with hash tables
> several years ago.

The idea of Eric was to shrink the reserved memory in an init script. I
doubt that the 1 TB machine will have any problems or performance issue
when booting with (1 TB - 32 GB) memory.

> It doesn't sound reasonable to Andi.
> 
> Why do you even want to grow the crash kernel that much? Is there
> any real problem with a 64-128MB crash kernel?

Try it out. No chance for 64-128MB crashkernel on "medium" IA64 machines.


Regards,
Bernhard
