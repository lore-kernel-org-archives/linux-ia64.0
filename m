From: Bruce Losure <blosure@sgi.com>
Date: Wed, 02 Mar 2005 19:36:57 +0000
Subject: Re: [PATCH 2.6.11-rc3 1/1] altix: Device driver support for the CX
Message-Id: <Pine.LNX.4.44.0503021328300.7612-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050228235822.16768.33715.29715@attica.americas.sgi.com>
In-Reply-To: <20050228235822.16768.33715.29715@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I've made all the changes you suggested and hope to resubmit today.

>
> the whole mbcs driver looks rather odd, what is it trying to do?
>

It's for current and upcoming FPGA based h/w.   Broadly speaking, the
FPGA contains two components a 'core services' component and a customer
component.    The core services are largely just dma engines and logic
to interact with the customer portion.   That's what the driver is
dealing with.

