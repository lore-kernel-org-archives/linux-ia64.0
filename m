From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 23:36:31 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <20040504233631.GD3395@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 04:31:26PM -0700, Grant Grundler wrote:
> Ok. Then IO Port and MMIO accesses will by default hardfail on ZX1.
> I believe there is only one bit that can be twiddled regarding this.

I'm wrong.
later chip revs added two more bits to "adjust"  I/O port failure mode.
(thanks alex)

grant
