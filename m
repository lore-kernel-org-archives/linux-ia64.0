From: Chris Wedgwood <cw@f00f.org>
Date: Wed, 16 Jun 2004 01:54:15 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <20040616015415.GA20876@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 05, 2004 at 10:15:56PM -0700, David Mosberger wrote:

> I'm not sure whether GCC ought to be emitting .pred.rel.mutex p6,p7
> or whether GAS is supposed to be smart enough to figure this out on
> its own.

I was just looking over the nested fault handler this thread came to
mind.

There is exactly that situation with '.pred.rel "mutex", p6, p7' where
gas should be able to infer this from the 'cmp.eq p6,p7 = 5,r17'
preceding this and there are no intermediate labels.

Perhaps there is a reason why gas works this way that I'm missing?



  --cw
