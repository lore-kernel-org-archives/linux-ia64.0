From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 21 Nov 2003 00:55:44 +0000
Subject: RE: Problems using psr.dd
Message-Id: <marc-linux-ia64-106937636521403@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Arch volume 2, section 5.3 is quite explicit, "A non-faulting
mandatory
> RSE load will clear PSR.da and PSR.dd".  This does not appear to be a
> problem when returning to user space with these bits set, probably
> because the context switch does loadrs.  AFAICT it is only an issue
> when using hardware debug registers on the kernel itself.  traps.c has
> to detect that it is returning to kernel state with either of these
> bits set and issue loadrs to ensure that the rfi does not require RSE
> loads.  Patch in progress.
> 
I think you meant the kernel return path (and not context switch) while
referring to loadrs above.  It is true that loadrs operation is done
only while transitioning to user space from kernel and not when you are
going back to kernel mode.  So for the kernel->kernel case rfi can lead
to mandatory RSE activity and thus clearing the da and dd bits.
> -
