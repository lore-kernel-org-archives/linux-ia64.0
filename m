From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 04 Apr 2005 07:09:57 +0000
Subject: Re: [PATCH] ULI 2.6.12
Message-Id: <20050404070957.GA4548@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050401130602.A123752@goliath.americas.sgi.com>
In-Reply-To: <20050401130602.A123752@goliath.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 04, 2005 at 10:22:37AM +1000, Peter Chubb wrote:
> However, I think that the thing that bothers me *most* about SGI's ULI
> approach is that a full context switch is not done.  The ULI runs as
> if it were in the interrupted process's context.  `current' isn't
> changed, so it runs with the privileges of the interrupted process.
> The *way* it runs (CPU bound, presumably) will affect the scheduler's
> decisions about how to run the interrupted process in the next
> timeslice.  For most interrupt handlers this won't matter, but it'd be
> relatively easy to construct a malicious one to slow particular
> processes.

I agree.  Raymonds version looks like a hack for a very narrow special
case to me.   I really prefer your more portable and useful version, and
I don't think the performance differences matter given today hardware.

