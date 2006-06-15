From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 15 Jun 2006 16:06:55 +0000
Subject: Re: light weight counters: race free through local_t?
Message-Id: <Pine.LNX.4.64.0606150858350.9193@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606092212200.4875@schroedinger.engr.sgi.com>
 <449033B0.1020206@bull.net> <Pine.LNX.4.64.0606140928500.4030@schroedinger.engr.sgi.com>
 <44915110.2050100@bull.net>
In-Reply-To: <44915110.2050100@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: akpm@osdl.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hmm... What about side effects such as pipeline stalls? fetchadd is 
semaphore operation. Typically we use acquire semantics for volatiles. 
Here the fetchadd has release semantics.

If we would use release semantics then the fetchadd would require all 
prior accesses to be complete.

Acquire semantics may be easier. But the best would be a fetchadd without 
any serialization that would be like the inc/dec memory on i386, which 
does not exist in the IA64 instruction set.

