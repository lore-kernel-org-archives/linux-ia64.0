From: Coywolf Qi Hunt <coywolf@gmail.com>
Date: Wed, 07 Sep 2005 08:52:17 +0000
Subject: Re: Prefetch kernel stacks to speed up context switch
Message-Id: <2cd57c900509070152518fac06@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509070829.j878TSg25898@unix-os.sc.intel.com>
In-Reply-To: <200509070829.j878TSg25898@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>

On 9/7/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> Repost previously discussed patch (on Jul 27, 2005). Ingo did
> the same thing for all arch with 471 lines of patch.  I'm still
> advocating this little 30 lines patch, of 6 lines introduces
> prefetch_stack() generic interface.
> 
> Andrew, please consider -mm inclusion. Or advise me what I need
> to do to take this forward.  Thanks.
> 
> - Ken

Do you have any benchmarks?
-- 
Coywolf Qi Hunt
http://sosdg.org/~coywolf/
