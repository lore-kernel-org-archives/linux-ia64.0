From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 21 Sep 2005 23:09:49 +0000
Subject: Re: MCA/INIT: need to wire CURRENT_STACK?
Message-Id: <ed5aea4305092116091b98a576@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16451.1127265127@ocs3.ocs.com.au>
In-Reply-To: <16451.1127265127@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/21/05, Keith Owens <kaos@sgi.com> wrote:
> On Wed, 21 Sep 2005 11:12:58 -0700,

> The virtual mode handlers are entered with psr.ic=1 and psr.i=0.

I'm not sure what you mean by virtual mode handlers, but execution in
the IVT starts with PSR.IC=0.

  --david
