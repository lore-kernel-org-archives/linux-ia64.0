From: cliff white <cliffw@osdl.org>
Date: Tue, 08 Feb 2005 23:32:43 +0000
Subject: Re: prezeroing V6 [2/3]: ScrubD
Message-Id: <20050208153243.13dd20de@es175>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	<1106828124.19262.45.camel@hades.cambridge.redhat.com>
	<20050202153256.GA19615@logos.cnet>
	<Pine.LNX.4.58.0502071127470.27951@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0502071131260.27951@schroedinger.engr.sgi.com>
	<20050207163035.7596e4dd.akpm@osdl.org>
	<Pine.LNX.4.58.0502071646170.29971@schroedinger.engr.sgi.com>
	<20050207170947.239f8696.akpm@osdl.org>
	<Pine.LNX.4.58.0502071710580.30068@schroedinger.engr.sgi.com>
	<20050207173559.68ce30e3.akpm@osdl.org>
	<Pine.LNX.4.58.0502080807410.3169@schroedinger.engr.sgi.com>
	<20050208122758.5c669281.akpm@osdl.org>
	<Pine.LNX.4.58.0502081249220.5796@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0502081249220.5796@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 8 Feb 2005 12:51:05 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 8 Feb 2005, Andrew Morton wrote:
> 
> > We also need to try to identify workloads whcih might experience a
> > regression and test them too.  It isn't very hard.
> 
> I'd be glad if you could provide some instructions on how exactly to do
> that. I have run lmbench, aim9, aim7, unixbench, ubench for a couple of
> configurations. But which configurations do you want?

If we can run some tests for you on STP let me know.
( we do 1,2,4,8 CPU x86 boxes )
cliffw


> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
