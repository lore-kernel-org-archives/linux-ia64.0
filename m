From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 12 Nov 2004 15:02:27 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <Pine.LNX.4.58.0411120700060.8932@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 12 Nov 2004, Robin Holt wrote:

> Are you saying that there is no way to solve this in a scalable fashion?

No. I am saying that a variety of approaches may be needed and I actually
got a raw draft of a patch here that allows to employ a variety of
ways of obtaining vm statistics.
