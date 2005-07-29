From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 08:39:51 +0000
Subject: RE: Add prefetch switch stack hook in scheduler function
Message-Id: <200507290839.j6T8dqg08486@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20050729083558.GA7302@elte.hu>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Ingo Molnar' <mingo@elte.hu>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote on Friday, July 29, 2005 1:36 AM
> * Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> > It generate slight different code because previous patch asks for a little
> > over 5 cache lines worth of bytes and it always go to the for loop.
> 
> ok - fix below. But i'm not that sure we want to unroll a 6-instruction 
> loop, and it's getting a bit ugly.

Yeah, I agree. We probably won't see a difference whether the loop is unrolled
or not.

