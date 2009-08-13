From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 13 Aug 2009 08:19:54 +0000
Subject: Re: [Patch 0/8] V3 Implement crashkernel=auto
Message-Id: <4A83CCAA.1030302@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain> <20090812124659.GA4808@mail1.bwalle.de> <4A837F49.9060003@redhat.com> <20090813053952.GA9037@mail1.bwalle.de>
In-Reply-To: <20090813053952.GA9037@mail1.bwalle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bernhard.walle@gmx.de>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Bernhard Walle wrote:
> Hi,
>
> * Amerigo Wang <amwang@redhat.com> [2009-08-13 04:49]:
>   
>> Bernhard Walle wrote:
>>     
>>> Honestly I don't see why everything is guarded by
>>> CONFIG_KEXEC_AUTO_RESERVE. We do we need that new configuration
>>> option? I mean, if I don't specify 'crashkernel=auto', then the patch
>>> does nothing, right? Then the option CONFIG_KEXEC_AUTO_RESERVE would
>>> only be needed so save some bytes of code. Is that really worth it?
>>>       
>> Hi,  CONFIG_KEXEC_AUTO_RESERVE is not for saving bytes, it just
>> provides a choice for the user to decide to enable it or not.
>>     
>
> Still, I don't understand it. When I don't say "crashkernel=auto" on
> command line, then nothing is done, right? So the choice for the user
> is the "crashkernel=auto". Why do we need CONFIG_KEXEC_AUTO_RESERVE
> then? Maybe I just missed something in my logic ...
>   
Sure.

But if we disable CONFIG_KEXEC_AUTO_RESERVE, that means crashkernel=auto 
will be invalid, this is the same as it is now.

