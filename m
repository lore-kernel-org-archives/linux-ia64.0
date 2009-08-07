From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 07 Aug 2009 22:16:43 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <m1tz0jmfqs.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>
	<m1eirqtmey.fsf@fess.ebiederm.org>
	<20090805140408.GJ7259@hmsreliant.think-freely.org>
	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>
	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com>
	<m1ljlxsiox.fsf@fess.ebiederm.org> <4A7A70E5.2010204@redhat.com>
	<m1bpmtqxjh.fsf@fess.ebiederm.org> <4A7A7A0F.6070906@redhat.com>
	<m1iqh1nxv3.fsf@fess.ebiederm.org> <4A7A9E54.60705@redhat.com>
	<m1iqgze740.fsf@fess.ebiederm.org> <4A7C9D48.3030405@gmx.de>
In-Reply-To: <4A7C9D48.3030405@gmx.de> (Bernhard Walle's message of "Fri\, 07 Aug 2009 23\:31\:52 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bernhard.walle@gmx.de>
Cc: Amerigo Wang <amwang@redhat.com>, Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>, Andi Kleen <andi@firstfloor.org>, Kexec Mailing List <kexec@lists.infradead.org>

Bernhard Walle <bernhard.walle@gmx.de> writes:

> Eric W. Biederman schrieb:
>> 
>> With the current set of crashkernel= options we are asking the
>> distribution installer to perform magic.  Moving as much of this logic
>> into a normal init script for better maintenance is desirable.
>
> Not (necessarily) the installer but the program that configures kdump.
> system-config-kdump on Red Hat, YaST on SUSE.

Right.  Somehow I thought YaST was the installer my mistake.

>> Bernhard does that sound useful to you?
>
> I don't see any problems. I don't know how much effort is it to free
> already reserved crashkernel memory, but I guess it's not really
> complicated. 

Right.

> Maybe that "1/32" should be specified on the command line like
>
>
> 	crashkernel=>>5
>
> (for 1/32*system_memory = system_memory>>5), OTOH I have no real strong
> opinion.

The idea is for the system to give us as much as it can stand and
userspace gives the rest back.  The maximum memory any particular
kernel can stand to give up is a tractable kernel level problem, and
we can make it autotune like any other kernel tunable.  What a crash
kernel needs totally depends on the implementation.

Eric
