From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 25 Feb 2008 17:05:29 +0000
Subject: Re: ia64_mca_cpe_int_handler
Message-Id: <47C2F559.1020707@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

1. irq_safe

"SAL runtime services are called from the following execution environment:
- Operating system runtime execution environment. The normal operating
  system execution environment is with translation on and interrupts
  enabled but the operating system may choose to call SAL runtime services
  in physical mode.
- Operating system machine check and initialization handler. The execution
  environment for these are provided by SAL and are in physical mode with
  interrupts disabled."

I read these paragraphs: we always call the SAL with interrupts enabled
unless we are in the MCA / INIT handlers. I.e. we could call

	SAL_GET_STATE_INFO(SAL_INFO_TYPE_MCA)
	SAL_GET_STATE_INFO(SAL_INFO_TYPE_INIT)
	SAL_CLEAR_STATE_INFO(SAL_INFO_TYPE_MCA)
	SAL_CLEAR_STATE_INFO(SAL_INFO_TYPE_INIT)

with interrupts enabled, when we are in a kernel process / interrupt handler
context.
Therefore "irq_safe" should come from the caller of ia64_mca_cpe_int_handler().

E.g. we could call SAL_GET_STATE_INFO(SAL_INFO_TYPE_MCA) at the start up of
the system with interrupts enabled, to see if the last reboot was due to a MCA,


2. I do not think using the same buffering mechanism for MCA and INIT as
we do for CMCI and CPEI is safe. You cannot take any lock in the 
MCA / INIT handlers.

I have not got any idea how the current code can be made safe.


3. disable_irq...() vs. local_irq_disable():

disable_irq...() is not local to the CPU, it costs ~10 microseconds.
You need to disable the polling interrupt, too.

I prefer to keep a spin_lock_irqsave() like semantics.


4. I'm thinking of a separate log buffer mechanism for the MCA handler:

- I'll have two log buffers for the MCA logs
- The 1st one keeps the 1st MCA, the 2nd one the last one
- I'll have an atomic variable that works as follows:
  + If it is 0, then there is nothing in the buffers
  + If it is 1, then there is exactly one, the 1st log there
  + If it is > 1, then:
    * If it is even, then the 2nd buffer is being updated
    * If if is odd, then it holds the last log

The MCA handler plays as follows:
- If the atomic variable is 0, it writes the 1st log, wmb(), sets the
  atomic variable to 1
- Else it increments the atomic variable, wmb(), it writes the "last" log,
  wmb(), increments the atomic variable. Should the "old value" of the
  atomic variable have become 0, restart...

The salinfo_decode side polls the atomic variable. If it is > 0, then
rmb(), it fetches the 1st log, if it is > 2 and odd, then it
fetches the last one, rmb(), it re-reads the the atomic variable,
if it has been incremented, then it re-fetches the last log...
Having read the logs, the salinfo_decode side can set the atomic
variable to 0.

The same mechanism duplicated for INIT.

I'd like to have you opinion in this idea, can you agree that this
mechanism will be 100% safe?


Thanks,

Zoltan Menyhart




