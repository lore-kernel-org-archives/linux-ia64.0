From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 05:57:57 +0000
Subject: Re: [Patch 0/7] Implement crashkernel=auto
Message-Id: <4A7A70E5.2010204@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain>	<m1eirqtmey.fsf@fess.ebiederm.org>	<20090805140408.GJ7259@hmsreliant.think-freely.org>	<m1skg5vpgg.fsf@fess.ebiederm.org> <4A7A3A78.7080200@redhat.com>	<m1y6pxr737.fsf@fess.ebiederm.org> <4A7A506B.2060008@redhat.com> <m1ljlxsiox.fsf@fess.ebiederm.org>
In-Reply-To: <m1ljlxsiox.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Neil Horman <nhorman@redhat.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>
>   
>>> No the crashdump mechanism is useless because user space is already
>>> broken and unusable.
>>>       
>> Again, why broken?
>>     
>
> To get a stock stat drive by hand I had to list about 5 kernel modules
> in the right magic order in /etc/kdump.conf
>
> Neither mount by label or mount by uuid when specified in /etc/kdump.conf
> I had to hack mkdumprd to get an initrd that even finds the proper disk
> to mount.
>   

You are saying that there is some difficulty to make a initrd for kdump, 
but I am sorry that I can't see any relations between this and my patch. 
What is your point here?

