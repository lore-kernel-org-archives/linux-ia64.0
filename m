From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 08 Jan 2007 23:29:42 +0000
Subject: Re: + make-initkmem_list3-non-init-data-to-fix-modpost-warning.patch
Message-Id: <Pine.LNX.4.64.0701081528570.11707@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0701081504380.11170@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701081504380.11170@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 8 Jan 2007, Andrew Morton wrote:

> Well yeah, but if you're sure that this warning is a false-positive
> then we could just leave it as-is and whack a comment in there.

Yes then lets add a comment. Isnt there some way to suppress the warning?

