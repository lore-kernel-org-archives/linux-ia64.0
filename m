From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 02 Sep 2005 15:38:09 +0000
Subject: Re: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <20050902153809.GA6300@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
In-Reply-To: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 02, 2005 at 10:36:12AM -0500, Mark Maule wrote:
> Add missing volatile qualifier to hardware MMR pointers in various SN files.
> Cosmetic code rearranging in pcibr_reg.c to avoid line-wraps.

Volatile usage is wrong most of the time, and your use is certainly.
It seems you're accessing mmio-space or something similar and should
use proper acessors for it.

