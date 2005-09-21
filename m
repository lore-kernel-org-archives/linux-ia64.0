From: Keith Owens <kaos@sgi.com>
Date: Wed, 21 Sep 2005 23:21:14 +0000
Subject: Re: MCA/INIT: need to wire CURRENT_STACK?
Message-Id: <14725.1127344874@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16451.1127265127@ocs3.ocs.com.au>
In-Reply-To: <16451.1127265127@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Sep 2005 16:09:49 -0700, 
David Mosberger-Tang <David.Mosberger@acm.org> wrote:
>On 9/21/05, Keith Owens <kaos@sgi.com> wrote:
>> On Wed, 21 Sep 2005 11:12:58 -0700,
>
>> The virtual mode handlers are entered with psr.ic=1 and psr.i=0.
>
>I'm not sure what you mean by virtual mode handlers,

The C code that starts with ia64_mca_handler and ia64_init_handler.
mca_asm.S is entered in physical mode with psr.ic=0, it switches to
virtual with psr.ic=1 and psr.i=0 before calling the handlers.

>but execution in
>the IVT starts with PSR.IC=0.

Right, so the real question is - is there any path that causes an
interrupt before the virtual mode handlers have accessed their stacks
and the required DTC has been created?  Alternatively can the DTC for
the MCA/INIT stacks be lost once the handlers have started running?

Given the uncertainty and the fact the the TLB error recovery in
mca_asm.S assumes that CURRENT_STACK is defined, I need to wire
CURRENT_STACK around the C code handlers.  Patch coming soon.

BTW David, are you aware that your mailer is using quoted printable,
even for plain text messages?  All the '=' signs come out as '='.

