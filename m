From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 05 Oct 2004 15:48:42 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <20041005164842.A19754@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>
In-Reply-To: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com>; from pfg@sgi.com on Mon, Oct 04, 2004 at 04:57:06PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Oct 04, 2004 at 04:57:06PM -0500, Pat Gefre wrote:
> 
> We have redone the I/O layer in the Altix code.
> 
> We've broken the patch set down to 2 patches. One to remove the files,
> the other to add in the new code. Most of the changes from the last
> posting are in response to review comments.

This looks pretty nice already, but a few small but important issues
need sorting out.

 - The interface between pci_dma.c and the lowlevel code is still wrong -
   and because of the additional 32bit direct translation in this code drop
   it got even worse because you might be calling into a function just to
   error out again.
   Please implement my suggestions from month ago, it's not a lot of work.
 - various sall baclls take bus_number and devfs but no pci domain, while
   the normal SAL calls do, I think you should make the kernel code aware
   of pci domains so the prom can introduce them seamlessly
 - is doing SAL calls from irq context really safe?  Also why do you need
   different SAL calls for shub vs ice error?  The prom should be easily
   able to find out what hub a given nasid corresponds to.
 - the patch reformats various unrelated or only slightly related files.
   Please don't do that - in general the new style is better than the old
   one, but it doesn't belong in this patchA
 - there's a SNDRV_SHUB_GET_IOCTL_VERSION ioctl define added but never
   used.  In fact it looks like all SNDRV_SHUB_ values are unused now?


