From: markw@osdl.org
Date: Fri, 26 Mar 2004 17:16:52 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <200403261716.i2QHGt205909@mail.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 25 Mar, David Mosberger wrote:
> Has anyone studied the impact of doing exponential backoff in
> ia64_spinlock_contention.  My theory is that it wouldn't buy much _if_
> spinlocks always were in their own cachelines, but since they're not,
> not using backoff could cause extra cache-line bouncing.  To be
> honest, I'd rather not spend time on this myself, since I don't have
> convenient access to large machines, but me thinks this is a question
> that's long overdue to have a proper answer.

We have 4-way Itanium2 systems here.  Is that large enough for testing?

Mark
