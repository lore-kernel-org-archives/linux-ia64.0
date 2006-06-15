From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 15 Jun 2006 15:56:42 +0000
Subject: Re: light weight counters: race free through local_t?
Message-Id: <Pine.LNX.4.64.0606150855410.9137@schroedinger.engr.sgi.com>
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

On Thu, 15 Jun 2006, Zoltan Menyhart wrote:

> My conclusion: let's stick to atomic counters.

Good to know. But we would run into trouble if the atomic counters would 
be contended.


