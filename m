From: Grant Grundler <iod00d@hp.com>
Date: Fri, 23 Jul 2004 19:53:26 +0000
Subject: Re: take2: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <20040723195326.GB31170@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE09B5.7020109@jp.fujitsu.com>
In-Reply-To: <40FE09B5.7020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 23, 2004 at 10:50:46PM +0900, Kenji Kaneshige wrote:
> What we need to prepare is vector spaces for each domain. So what
> we need to change is 'iosapic_intr_info' array, assign_irq_vector(),
> and so on..

Yes - I agree multi-vector domanins is more work and more code change.
But I'm very inclined to believe the benefit is greater too based
on past work I've done.

thanks,
grant
