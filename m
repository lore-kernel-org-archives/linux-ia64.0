From: Anton Altaparmakov <aia21@cam.ac.uk>
Date: Thu, 02 Feb 2006 08:52:11 +0000
Subject: Re: [PATCH 1/12] generic *_bit()
Message-Id: <Pine.LNX.4.64.0602020849160.785@hermes-2.csi.cam.ac.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201193933.GA16471@esmail.cup.hp.com>
 <200602012141.k11LfCg32497@unix-os.sc.intel.com> <20060201220903.GE16471@esmail.cup.hp.com>
 <Pine.LNX.4.64.0602012246330.3680@hermes-2.csi.cam.ac.uk>
 <20060202000820.GI16471@esmail.cup.hp.com>
In-Reply-To: <20060202000820.GI16471@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Hellwig' <hch@infradead.org>, 'Akinobu Mita' <mita@miraclelinux.com>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Wed, 1 Feb 2006, Grant Grundler wrote:
> On Wed, Feb 01, 2006 at 10:49:08PM +0000, Anton Altaparmakov wrote:
> > Err, searching by anything other than bytes is useless for a file system 
> > driver.  Otherwise you get all sorts of disgustingly horrible allocation 
> > patterns depending on the endianness of the machine...
> 
> Well, tell that to ext2/3 maintainers since they introduced
> the ext2_test_bit() and friends. They do require LE handling
> of the bit array since that's an on-disk format. See how big endian
> machines (parisc/ppc/sparc/etc) deal with it in asm/bitops.h.

Oh, I hadn't noticed those before.  Thanks.

The name seems a bit silly as I imagine most fs drivers would be able to 
use them and there already are ext2 and minix versions.  Probably ought 
be renamed to a more generic name like le_test_bit() or something...

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer / IRC: #ntfs on irc.freenode.net
WWW: http://linux-ntfs.sf.net/ & http://www-stu.christs.cam.ac.uk/~aia21/
