From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 10 Mar 2006 09:54:47 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <44114CE7.9080700@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart schrieb:

> The only instruction I know of to synchronize with the "itc" mechanism is
> the "srlz" instruction. 

rfi implies srlz.i (and srlz.d) as well.

Christian

