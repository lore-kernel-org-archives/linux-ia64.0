From: Amerigo Wang <amwang@redhat.com>
Date: Thu, 06 Aug 2009 07:56:51 +0000
Subject: Re: [Patch 1/7] x86: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <4A7A8CC3.9060901@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090805112123.6552.73574.sendpatchset@localhost.localdomain> <20090805112133.6552.69619.sendpatchset@localhost.localdomain> <87zlaeiakr.fsf@basil.nowhere.org> <4A7A3807.8090803@redhat.com> <20090806071526.GA22124@basil.fritz.box>
In-Reply-To: <20090806071526.GA22124@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Andi Kleen wrote:
> Hardcoding the size doesn't really make any sense to me, especially
> a suspicious one like 128MB.
>   

Er, don't worry about this is too large, I am working on a patch which 
will allow us to remove the unnecessary reserved memory from user space. :)

