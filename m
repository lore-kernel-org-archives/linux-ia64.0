From: david mosberger <dmosberger@gmail.com>
Date: Fri, 19 Aug 2005 18:30:44 +0000
Subject: Re: Understanding XIP, XPSR, XFS registers
Message-Id: <ed5aea430508191130d6e7c78@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8491.1124435294@kao2.melbourne.sgi.com>
In-Reply-To: <8491.1124435294@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The manual is correct.  You can see that in the (old) MCA backtrace
code where we pick up the state from the X registers if PSR.ic=0.  I
verified at some point that this works as well as it can.

  --david

On 8/19/05, Keith Owens <kaos@sgi.com> wrote:
> Resuming after MCA/INIT when psr.ic = 1 is relatively easy and it
> appears to work with the new MCA/INIT handlers.  Resuming after
> MCA/INIT when psr.ic = 0 (i.e. the event occurred in an interrupt
> handler) is proving to be a problem.
> 
> When MCA/INIT occurs and psr.ic = 0, what is in X{IP,PSR,FS} in PAL
> minstate?  Is it the original values of I{IP,PSR,FS}, with I{IP,PSR,FS}
> replaced by the values when MCA/INIT was delivered?  Or is I{IP,PSR,FS}
> left alone (i.e. they still contain the values delivered to the
> interrupt handler), with X{IP,PSR,FS} set to the values when MCA/INIT
> was delivered?
> 
> Common sense says that I{IP,PSR,FS} is left alone when psr.ic = 0, with
> the new values being stored in X{IP,PSR,FS}.  However Intel Itanium
> Architecture Software Developer's Manual Volume 2: System Architecture
> (24531804.pdf), 11.3.3 Returning to the Interrupted Process, implies
> the reverse.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
