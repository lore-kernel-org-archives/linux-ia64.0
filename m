From: Christoph Lameter <christoph@lameter.com>
Date: Wed, 19 Jan 2005 16:54:09 +0000
Subject: Re: time to reconsider HZ?
Message-Id: <Pine.LNX.4.58.0501190852300.26378@server.graphe.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16872.45685.696721.811934@napali.hpl.hp.com>
In-Reply-To: <16872.45685.696721.811934@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 14 Jan 2005, David Mosberger wrote:

> Since most other Linux platforms which use HZ>100 use a HZ value of
> 1000, I'm thinking it may be safer to switch ia64 to HZ00 as well
> (principle of least difference possible is generally a good one...).
>
> In the past, I was concerned that there might be enough code that
> divides by HZ that this might not be such a hot idea, but I think this
> may not (or at least no longer) be the case: I compiled the same
> kernel once with HZ00 and once with HZ24 and the code-size
> actually shrunk.
>
> What do others think?

I think its not a big issue and may still be beneficial if occasions arise
where one has to divide by HZ. Do you know why the code size is reduced?

