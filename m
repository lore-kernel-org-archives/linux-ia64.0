From: Andrew Morton <akpm@osdl.org>
Date: Thu, 22 Sep 2005 20:15:21 +0000
Subject: Re: [PATCH] Increase maximum kmalloc size to 256K
Message-Id: <20050922131521.77da1684.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509221306380.18133@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509221306380.18133@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, manfred@colorfulllife.com

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
>  The workqueue structure can grow larger than 128k under 2.6.14-rc2 (with 
>  all debugging features enabled on 64 bit platforms)

Would it be better to use alloc_percpu() in there?  Bearing in mind that
one day we'll probably have an alloc_percpu() which incurs one less
indirection and which allocates things node-affinely.

