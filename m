From: Andrew Morton <akpm@osdl.org>
Date: Tue, 08 Feb 2005 00:30:35 +0000
Subject: Re: prezeroing V6 [2/3]: ScrubD
Message-Id: <20050207163035.7596e4dd.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	<1106828124.19262.45.camel@hades.cambridge.redhat.com>
	<20050202153256.GA19615@logos.cnet>
	<Pine.LNX.4.58.0502071127470.27951@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0502071131260.27951@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0502071131260.27951@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> Adds management of ZEROED and NOT_ZEROED pages and a background daemon
> called scrubd.

What were the benchmarking results for this work?  I think you had some,
but this is pretty vital info, so it should be retained in the changelogs.

Having one kscrubd per node seems like the right thing to do.

Should we be managing the kernel threads with the kthread() API?
