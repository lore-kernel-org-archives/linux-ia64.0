From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 31 Oct 2014 09:09:13 +0000
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound violation information
Message-Id: <alpine.DEB.2.11.1410311007230.5308@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <5452BDD8.2080605@intel.com> <5452EFF7.4090204@intel.com>
In-Reply-To: <5452EFF7.4090204@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ren Qiaowei <qiaowei.ren@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Fri, 31 Oct 2014, Ren Qiaowei wrote:
> On 10/31/2014 06:38 AM, Dave Hansen wrote:
> > > @@ -316,6 +317,11 @@ dotraplinkage void do_bounds(struct pt_regs *regs,
> > > long error_code)
> > >   		break;
> > > 
> > >   	case 1: /* Bound violation. */
> > > +		do_mpx_bounds(regs, &info, xsave_buf);
> > > +		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs,
> > > +				error_code, &info);
> > > +		break;
> > > +
> > >   	case 0: /* No exception caused by Intel MPX operations. */
> > >   		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code,
> > > NULL);
> > >   		break;
> > > 
> > 
> > So, siginfo is stack-allocarted here.  do_mpx_bounds() can error out if
> > it sees an invalid bndregno.  We still send the signal with the &info
> > whether or not we filled the 'info' in do_mpx_bounds().
> > 
> > Can't this leak some kernel stack out in the 'info'?
> > 
> 
> This should check the return value of do_mpx_bounds and should be fixed.

And how's that answering Dave's question about leaking stack information? 

Thanks,

	tglx
