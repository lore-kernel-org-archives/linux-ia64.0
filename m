From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 20 May 2004 15:26:39 +0000
Subject: Re: [PATCH] early console registration
Message-Id: <200405201126.39939.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, May 20, 2004 11:18 am, Bjorn Helgaas wrote:
> The interesting bit to me is setting CPU 0 online early.  We've
> already set up I/O port space and the machine vector, so that
> should be OK.  We haven't done cpu_init() yet, so the per-CPU
> data mapping isn't set up yet.  I guess it's probably reasonable
> to prohibit early console drivers from using per-CPU data.

Yeah, that's a good point.  In the comments above the early console setup 
function we should outline the requirements and restrictions for a console 
registered there.  So far we've got:
  o cannot allocate memory
  o cannot use per-cpu data
  o cannot use interrupts

What else?

Jesse
