From: Arjan van de Ven <arjan@infradead.org>
Date: Fri, 06 Jan 2006 08:38:18 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <1136536698.2940.5.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060105213948.11412.45463.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060105213948.11412.45463.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hawkes@sgi.com
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Thu, 2006-01-05 at 13:39 -0800, hawkes@sgi.com wrote:
> Increase the generic ia64 config from its current max of 512 CPUs to a
> new max of 1024 CPUs.

I wonder why this would be seen as a sane thing...
Very few people have 1024 cpus, and the ones that do sure would know how
to set 1024 in their kernel config. In fact I would argue to lower it. I
can see the point of keeping it over 64, to give the
more-cpus-than-a-long code more testing, but 512 is too high already..
most people who have ia64 will not have 512 cpus.

(and please don't say "but distributions.." because distributions don't
use the defconfigs anyway)


