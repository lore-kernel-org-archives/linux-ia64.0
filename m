From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 05 Dec 2005 19:24:40 +0000
Subject: Re: [PATCH 1/3] Arch specific zone reclaim framework
Message-Id: <Pine.LNX.4.62.0512051122280.12133@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
 <20051205191159.GB28433@infradead.org>
In-Reply-To: <20051205191159.GB28433@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 5 Dec 2005, Christoph Hellwig wrote:

> Nack.  Arch control over VM reclaim logic will load to a total mess with VM
> logic all over arch.  Please introduce a framework that allows individual
> machines control parameters, but procedural callouts are a big no-no.

The different penalties for off node accesses on various architectures may 
dictate different techniques in order to get best performance . The 
parameter control was tried before and it was not nice. IMHO this is the 
cleanest possible solution.



