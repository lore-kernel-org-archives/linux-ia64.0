From: n0ano@n0ano.com
Date: Tue, 29 Jun 2004 14:11:07 +0000
Subject: Re: Why large stack frame for PAL call
Message-Id: <20040629141106.GA23246@tlaloc.n0ano.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
In-Reply-To: <200406271740.i5RHeaY24803@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I can neither confirm nor deny these allegations (I think I've been
watching CSPAN too much :-)

I don't remember this code at all but my guess is that we did it
to be overly conservative about saving registers.  Back then, especially
in a simulated environment, we didn't trust anything.  As you say, most
likely we didn't trust PAL to save things properly so we made sure
it wouldn't be a problem.

If PAL doesn't touch the stack registers then it should be safe to
remove this.

On Mon, Jun 28, 2004 at 10:50:15PM -0700, David Mosberger wrote:
> >>>>> On Sun, 27 Jun 2004 10:42:14 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:
> 
>   Ken> Does anyone know why we need such large stack frame for PAL
>   Ken> static call?  PAL isn't even suppose to touch any stack
>   Ken> register for static calling convention.  Is it for legacy
>   Ken> reason or something?
> 
> Good question.  I was able to track the source down to a patch that
> was sent to me by Walt Drummond on Aug 11, 1999.  The authors listed
> in the relevant file (it was called palcall.S back then) were Don
> Dugger and Walt Drummond (in this order), so my guess is the code was
> originally written by Don.  At that time, the primary target for Don
> would have been SoftSDV.  Perhaps it was to work around a bug in
> SoftSDV, though I suspect it's just as likely that the code came about
> by a misunderstood/misdocumented PAL-requirement.
> 
> Perhaps Don or Asit remember how this came about?
> 
> I also cannot find a requirement that would demand allocating 96
> stacked registers before making a PAL call and I'd be in favor of
> cleaning that up.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/447-2201
