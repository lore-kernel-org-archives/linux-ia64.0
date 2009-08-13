From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 13 Aug 2009 10:49:24 +0000
Subject: Re: [Patch 0/8] V3 Implement crashkernel=auto
Message-Id: <m1k5182dl7.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812124659.GA4808@mail1.bwalle.de> <4A837F49.9060003@redhat.com>
	<20090813053952.GA9037@mail1.bwalle.de> <4A83CCAA.1030302@redhat.com>
	<20090813090335.GA9502@mail1.bwalle.de>
In-Reply-To: <20090813090335.GA9502@mail1.bwalle.de> (Bernhard Walle's message of "Thu\, 13 Aug 2009 11\:03\:35 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bernhard.walle@gmx.de>
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Bernhard Walle <bernhard.walle@gmx.de> writes:

> * Amerigo Wang <amwang@redhat.com> [2009-08-13 10:19]:
>> Sure.
>> 
>> But if we disable CONFIG_KEXEC_AUTO_RESERVE, that means
>> crashkernel=auto will be invalid, this is the same as it is now.
>
> Ok, but since 'crashkernel=auto' is not used today, nobody has
> 'crashkernel=auto' in the bootloader configuration. So I don't see any
> practial advantage of that config option.
>
> Eric, what's your opinion on that, do we need a config option
> CONFIG_KEXEC_AUTO_RESERVE or could we just implement that feature
> unconditionally (if CONFIG_KEXEC is enabled, of course).

The only reason I can see the option going away would be
a dependency on CONFIG_HOTPLUG_MEM.

Eric
