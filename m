From: Andrew Morton <akpm@osdl.org>
Date: Mon, 08 Jan 2007 23:27:12 +0000
Subject: Re: +
Message-Id: <20070108152712.ead32a63.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 8 Jan 2007 15:11:38 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 8 Jan 2007, Christoph Lameter wrote:
> 
> > On a IA64 system (allows up to 1024 node nodes) this will be wasting 212 
> > kbyte. Some IA64 boxes only have 1 Gigabyte of memory. So we may end up
> > wasting 1/5th of all available memory.
> 
> Crap. This is okay. 212k is 1/5th of 1 Megabyte....
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>

Well yeah, but if you're sure that this warning is a false-positive
then we could just leave it as-is and whack a comment in there.
