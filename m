From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 11 May 2004 07:06:21 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <20040511080621.A12817@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 11, 2004 at 12:02:34AM -0700, David Mosberger wrote:
> 
> <pfg@sgi.com> (04/05/06 1.1587.10.10)
>    [PATCH] ia64: SN2 - remove node_first_cpu member
>    
>    Remove node_first_cpu member from nodepda_s and replace its usage with calls
>    to sn_get_node_first_cpu().

This should still use the topology API even if Pat decided to ignore the
review.

