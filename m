From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 23:15:15 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16536.9219.804679.845885@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 May 2004 16:11:35 -0700, Grant Grundler <iod00d@hp.com> said:

  Grant> HP chipsets (ZX1/SX1000) will hardfail - it's one of the
  Grant> differences I point out in the "Porting drivers to ZX1"
  Grant> OLS2002 paper I wrote.  Sounds like SGI chipsets behave the
  Grant> same way.

Hmmh, I thought zx1 soft-fails on inX/outX?

	--david
