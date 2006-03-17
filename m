From: Carsten Otte <cotte@de.ibm.com>
Date: Fri, 17 Mar 2006 13:53:04 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <441ABF40.4060805@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net> <441ABEDD.4070003@de.ibm.com>
In-Reply-To: <441ABEDD.4070003@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: carsteno@de.ibm.com
Cc: Jes Sorensen <jes@sgi.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Hellwig <hch@lst.de>

Carsten Otte wrote:
> If you use address as parameter to nopfn, it won't work with highmem
> on 32bit systems. Alternative would be to use (unsigned long) phys. page
> frame number.
Me stupid. I mean return value not address parameter.

Carsten
