From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 29 Aug 2000 18:52:34 +0000
Subject: Re: [Fwd: [Fwd: [Linux-ia64] ia64 redhat 7 beta]]
Message-Id: <marc-linux-ia64-105590678205411@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205407@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205407@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Doug Beattie wrote:

> 1. Does anyone else have a problem getting into the Qlogic Fast!Util
> on their IA64 system?

Yes.  Don't bother entering Qlogic setup on BigSurs -- the system will hang.

> I have to place the card into a 32 bit system to access the bios and
> make a change, then place it back into my BigSur to try it.

I was able to boot both test6 and test7 kernels on BigSurs without any Qlogic
BIOS changes.  I had to enable >4G addressing on Lion systems when booting
test6 kernels.

Uros

--
Uros Prestor
uros@turbolinux.com




