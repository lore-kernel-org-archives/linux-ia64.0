From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 23:31:26 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <20040504233126.GC3395@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 04:17:30PM -0700, Jesse Barnes wrote:
> That's nice (that's why I wanted a pointer to a spec--I can hand it to our hw 
> guys who have been asking for it).

Well, ask Intel. Nicely. :^)

> Alex says that zx1 can soft fail on IO port accesses if configured to do so.  

Ok. Then IO Port and MMIO accesses will by default hardfail on ZX1.
I believe there is only one bit that can be twiddled regarding this.

grant
