From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 24 Apr 2002 23:13:08 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905516@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 23, 2002 at 11:43:45PM -0700, David S. Miller wrote:
>    > Eh? You tell me that first.  You totally ignore my performance points
>    > and this makes it very difficult to discuss this issue with you.
>    
>    I understand that the performance will be lower, but out of curiosity,
>    do you know by how much?  Have you tried running (say) qlogicfc with
>    32 and 64 bit consistent addresses to measure the difference?
>    
> Every descriptor fetch will use two address cycles instead of
> one, I mean, do the math.

Ok, there are _many_ cards that can handle 64 bit coherent pointers,
including qlogic 1040, 1240, 1080, 1280, 12160, 2100, 2200, 2300,
2310, 2342, adaptec/jni 1160 (and followons, presumably).  The extra
address cycle is *rarely* an issue under most loads (e.g. on a 64k
scsi i/o, using SAC saves you 2 or 3 cycles out of 8000).  The
advantage of using 64 bit mappings is that you save 32 bit mappings
for cards that really need them.

So the penalty for using DAC comes down to ~.0375% for a 64k I/O, and
the benefit is that you don't have to use 32 bit mappings (which can
be scarce on some platforms).

In short, please reconsider your opposition to adding a
pci_dac_page_to_consistent type call.  It's an easy thing to add...

Thanks,
Jesse

