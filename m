From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 22:07:41 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16878.55853.372937.95660@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 13:51:45 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> Something like this then?

Shouldn't the #ifdef test be for CONFIG_EFI rather than ia64?

	--david
