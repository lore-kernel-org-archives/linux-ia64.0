From: Dan Pop <Dan.Pop@cern.ch>
Date: Sat, 17 Jun 2000 21:07:12 +0000
Subject: Re: [Linux-ia64] Bitcount ?
Message-Id: <marc-linux-ia64-105590678205162@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Sat, 17 Jun 2000, Dimo Dimitrov-DataManagement wrote:

> I need an algoritm to do bitcount across an array, which ran in less than a
> cycle/byte on IA32/IA64.
> I have written an algoritm for bit-parallel adition, and the best time wich
> I get is ~1.4 c/b.

I'm not sure I've understood what exactly your problem is, but did you
look at the popcnt instruction?

Dan 



