From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 08 Jan 2007 23:11:38 +0000
Subject: Re: + make-initkmem_list3-non-init-data-to-fix-modpost-warning.patch
Message-Id: <Pine.LNX.4.64.0701081510500.11528@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0701081504380.11170@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701081504380.11170@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 8 Jan 2007, Christoph Lameter wrote:

> On a IA64 system (allows up to 1024 node nodes) this will be wasting 212 
> kbyte. Some IA64 boxes only have 1 Gigabyte of memory. So we may end up
> wasting 1/5th of all available memory.

Crap. This is okay. 212k is 1/5th of 1 Megabyte....

Acked-by: Christoph Lameter <clameter@sgi.com>

