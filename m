From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 15 Jun 2006 21:48:26 +0000
Subject: RE: Why does ia64 not use fetchadd in atomic.h?
Message-Id: <Pine.LNX.4.64.0606151447370.10880@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606151323380.10549@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606151323380.10549@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 15 Jun 2006, Chen, Kenneth W wrote:

> I guess I got confused, are you complaining about ia64_atomic_add or
> ia64_atomic64_add?  If the former, there is not much can be done, but if
> the latter, yeah, it can be optimized for certain constant.

No complaints. I was just looking for an explanation.

