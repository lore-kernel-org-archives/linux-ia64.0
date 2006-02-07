From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Tue, 07 Feb 2006 21:19:08 +0000
Subject: Re: [patch 3/6] prefetch bottom of kernel rbs stack at syscall exit path
Message-Id: <ed5aea430602071319h1d722037h6b56f2fd1477b2a3@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310913.k0V9DWg13193@unix-os.sc.intel.com>
In-Reply-To: <200601310913.k0V9DWg13193@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 2/6/06, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> Chen, Kenneth wrote on Tuesday, January 31, 2006 11:27 AM
> > David Mosberger-Tang wrote on Tuesday, January 31, 2006 9:45 AM
> > > How much latency does this add for a minimal syscall when
> > > everything is cached?
> >
> > I will get the measurement out shortly.
>
> Here are the numbers for break based getpid():
>
> Vanilla 2.6.15:    238 cycles
> Vanilla + patches: 250 cycles

Hmmh, 12 cycles lost.  Can you see if you can do better?  There really
are apps out there that care about this case (not getpid per se, but
minimal syscall entry/exit overhead when everything is cached).

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
