From: stefan <stefan@lkcc.org>
Date: Fri, 21 Sep 2001 14:11:37 +0000
Subject: Re: [Linux-ia64] getcontext() correctly implemented ?
Message-Id: <marc-linux-ia64-105590698805236@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805230@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805230@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 20 Sep 2001, David Mosberger wrote:

> You didn't mention the register backing store.  Be sure to scan that
> one too!  For the main thread, libc exports a global variable which
> will help you find the beginning of the backing store.  The variable
> is called "__libc_ia64_register_backing_store_base".  I'm not sure
> what pthreads does (Hans can you help?).  The top of the register
> backing store can be obtained from the "sc_bsp" member in the ucontext
> (uc->uc_mcontext.sc_bsp).

Wow ! This fixed this specific problem. With a little change:
uc->uc_mcontext.sc_bsp is uc->uc_mcontext.sc_ar_bsp.

Thanks a lot,
	stefan@lkcc.org


