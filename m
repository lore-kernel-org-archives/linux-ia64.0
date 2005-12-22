From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 22 Dec 2005 10:36:06 +0000
Subject: Re: [PATCH 2/4] msi vector targeting abstractions
Message-Id: <20051222103606.GA29608@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184348.5003.7540.53186@attica.americas.sgi.com> <20051221190558.GD2361@parisc-linux.org> <20051221193300.GK9920@sgi.com>
In-Reply-To: <20051221193300.GK9920@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

> Mainly I did it this way 'cause msg_address seems to be geared toward specific
> hw (apic?).  In the case of altix interrupt hw, we don't know about
> dest_mode et. al., but only care about the raw address.

In that case you should probably kill the struct as I suggested and only
keep the shift & mask defines in the file for the apic hw implementation.

