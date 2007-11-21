From: Kyle McMartin <kyle@mcmartin.ca>
Date: Wed, 21 Nov 2007 02:43:26 +0000
Subject: Re: [PATCH] set_thread_area fails in IA32 chroot
Message-Id: <20071121024326.GA12364@fattire.cabal.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071120031246.GB29070@cse.unsw.EDU.AU>
In-Reply-To: <20071120031246.GB29070@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Nov 20, 2007 at 02:12:46PM +1100, Ian Wienand wrote:
> I think the solution is flushing the tls array on exec as below.
> 

It is indeed. I had debugged this too but haven't had time to
play with my ia64 boxes recently and clean it up and submit.

Good catch.

cheers,
	Kyle

> Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>
Acked-by: Kyle McMartin <kyle@mcmartin.ca>

