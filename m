From: Dimitri Sivanich <sivanich@sgi.com>
Date: Thu, 16 Mar 2006 16:01:02 +0000
Subject: Re: [PATCH] Fix percpu interrupt allocation in mmtimer code
Message-Id: <20060316160102.GF24867@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060315143906.GE29195@sgi.com>
In-Reply-To: <20060315143906.GE29195@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 16, 2006 at 03:56:06PM +0000, Christoph Hellwig wrote:
> Rather than letting the driver poke into irq code internals I'd suggest
> you fux the request_irq code to properly support SA_PERCPU_IRQ.
Good suggestion.  I'll make the appropriate changes.
