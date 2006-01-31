From: Grant Grundler <iod00d@hp.com>
Date: Tue, 31 Jan 2006 18:14:01 +0000
Subject: Re: [PATCH 8/12] generic hweight{32,16,8}()
Message-Id: <20060131181401.GB10640@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060131164949.3365.qmail@science.horizon.com>
In-Reply-To: <20060131164949.3365.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux@horizon.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mita@miraclelinux.com

On Tue, Jan 31, 2006 at 11:49:49AM -0500, linux@horizon.com wrote:
> This is an extremely well-known technique.  You can see a similar version
> that uses a multiply for the last few steps at
> http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
> whch refers to 
> "Software Optimization Guide for AMD Athlon 64 and Opteron Processors"
> http://www.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/25112.PDF
...

> The next step consists of breaking up b (made of 16 2-bir fields) into
> even and odd halves and adding them into 4-bit fields.  Since the largest
> possible sum is 2+2 = 4, which will not fit into a 4-bit field, the 2-bit
> fields have to be masked before they are added.

Up to here, things were clear.
My guess is you meant "which will not fit into a 2-bit field".

thanks,
grant
