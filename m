From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 05 Nov 2003 16:14:33 +0000
Subject: Re: Fix compiler warning in arch/ia64/kernel/irq_lsapic.c
Message-Id: <marc-linux-ia64-106804908606025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106804372231040@msgid-missing>
In-Reply-To: <marc-linux-ia64-106804372231040@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 05, 2003 at 08:44:26AM -0600, Jack Steiner wrote:
> Not sure if you are taking fixes like this right now, but...
> 
> This fixes a compoiler warning that occurs when NR_CPUS is > 64.

I think the right fix would be to just not set this value, IIRC
set_affinity is optional.

--
Christoph Hellwig <hch@lst.de>		-	Freelance Hacker
Contact me for driver hacking and kernel development consulting
