From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 05 Dec 2005 19:11:59 +0000
Subject: Re: [PATCH 1/3] Arch specific zone reclaim framework
Message-Id: <20051205191159.GB28433@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Nack.  Arch control over VM reclaim logic will load to a total mess with VM
logic all over arch.  Please introduce a framework that allows individual
machines control parameters, but procedural callouts are a big no-no.
