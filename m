From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 06 Aug 2009 07:15:27 +0000
Subject: Re: [Patch 1/7] x86: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <20090806071526.GA22124@basil.fritz.box>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> <20090805112133.6552.69619.sendpatchset@localhost.localdomain> <87zlaeiakr.fsf@basil.nowhere.org> <4A7A3807.8090803@redhat.com>
In-Reply-To: <4A7A3807.8090803@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

>> More useful would seem a crashkernel=size@auto
>>   
> We already have this, just use "crashkernel=size@0". :)

When it's already there then I don't see the point of the feature at all.

Hardcoding the size doesn't really make any sense to me, especially
a suspicious one like 128MB.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
