From: Chuck Fleckenstein <cfleck@co.intel.com>
Date: Wed, 15 Mar 2000 16:49:39 +0000
Subject: Re: [Linux-ia64] INIT switch handler
Message-Id: <marc-linux-ia64-105590678204985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204984@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204984@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The init handler in arch/ia64/kernel/mca.c doesn't do anything yet.  Does
> anyone have plans for what such a handler should or will do on Linux?
> 
> When the init switch is pressed, it causes a reset of the processor(s). The
> purpose of the init
> switch on Lion is the same as the NMI switch on the IA-32 platforms. The
> OS will have to write a handler that will check and see that the init
> switch has been pressed and dump the state of the processor and the state
> of the system.
>  

funny you should mention that.  I hacked on this 
code yesterday and it is building now in my local sandbox and have it at least 
making the appropriate SAL calls to register the handlers without
dying during boot.  My first plan of attack once I get init handler called is
to have it dump the state info and call the debugger.
I've also been talking to the internal hardware dudes about INIT and
the NMI paths.

I'll submit a patch to David for the build/cleanup portion of this and
will continue to debug the handler path.

Other ideas on this subject ?

Chuck


Chuck Fleckenstein
Intel IPD
cfleck@co.intel.com



