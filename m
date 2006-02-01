From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 01 Feb 2006 03:13:48 +0000
Subject: Re: [patch 5/6] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <ed5aea430601311913x4ca6f869gc73cac6a531aeb09@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310928.k0V9Seg14417@unix-os.sc.intel.com>
In-Reply-To: <200601310928.k0V9Seg14417@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 1/31/06, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> David Mosberger-Tang wrote on Tuesday, January 31, 2006 9:40 AM
> > To be safe, I think you need to default to the maximum number of
> > physical stacked registers (which is somewhere around 16,384, based on
> > the width of the ARC.RSC.LOADRS field).
>
> Do I really need to do that?  I'm checking physical stack register
> size at time of cpu_init() and patch the kernel code to use largest
> size found in the entire system.  Wouldn't that be enough?

If the code in question can be executed before the patching is done,
then yes.  Otherwise, no.  If the latter, I'd, however, initialize
with an instruction that noticably fails when it gets executed
(perhaps some sort of "break" instruction).

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
