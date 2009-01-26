From: Robin Holt <holt@sgi.com>
Date: Mon, 26 Jan 2009 12:58:21 +0000
Subject: Re: Gateway DX4720-03 apic problem
Message-Id: <20090126125821.GG8577@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <497CADF6.10703@macslab.com>
In-Reply-To: <497CADF6.10703@macslab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Jan 25, 2009 at 10:22:46AM -0800, Charles Landau wrote:
> I have a new Gateway DX4720-03 PC and have discovered that it won't  
> install Fedora 10 unless I give the kernel boot option "noapic" or  
> "nolapic".
>
> This system's processor is the Intel Pentium Dual Core E5200.
>
> It would seem that this is either a kernel bug to be fixed, or a  
> documentation bug so users of this machine know about the workaround.  
> I'll report the bug if someone will tell me how.

This is definitely the wrong list, but we tend to be somewhat helpful ;)

You should probably start by sending mail to linux-kernel@vger.kernel.org
mailing list and then adding the following people to the Cc: list:

Ingo Molnar <mingo@elte.hu>
Andrew Morton <akpm@linux-foundation.com>
Andi Kleen <andi@firstfloor.org>
Eric Biederman <ebiederm@xmission.com>
Suresh Siddha <suresh.b.siddha@intel.com>
Yinghai Lu <yhlu.kernel@gmail.com>

I am sure I missed some, but that is a good place to start.

Thanks,
Robin
