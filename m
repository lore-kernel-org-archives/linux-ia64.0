From: Martin Pool <mbp@samba.org>
Date: Wed, 14 May 2003 02:32:17 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 13 May 2003, David Mosberger <davidm@napali.hpl.hp.com> wrote:

> It strikes me that for a really reliable crash-dump, you'd want to
> read _all_ the bits needed to do the dumping from ROM.

But you also need to know which disk to write to, and where.  And
presumably "which disk" actually means knowing the PCI path to the
SCSI host adapter, and then the path to the disk.  "Where" might be
just the index of start block, if you reserved a contiguous partition,
or it might be more complex.  If any of this got screwed up, you might
write your dump over /home instead -- and then rather than a possibly
once-off kernel crash, you've lost lots of data.

So for a really reliable dump, you'd want to check and "lock down"
these variables at startup into a region of memory not easily changed
by the kernel, and accessible by EFI.  NVRAM?  I don't know if there's
anything suitable on IPF.

It would be an interesting project, although since network dumps run a
lower risk of clobbering filesystems they're probably a smarter
design.  It would be cool to do it in EFI, if that's possible.

> Assuming you have a (minimal) disk driver/network driver written in
> EFI byte code, all you'd need is the EFI byte-code interpreter which
> hopefully would fit in a fixed (and reasonable) amount of space.
> Hence you could reserve some memory for this purpose and on a crash,
> load the byte-code interpreter from ROM and get going that way.

-- 
Martin 

