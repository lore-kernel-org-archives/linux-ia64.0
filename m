From: Khalid Aziz <khalid_aziz@hp.com>
Date: Tue, 16 Nov 2004 17:28:27 +0000
Subject: RE: [PATCH] kexec on ia64
Message-Id: <1100626107.21234.2.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100550721.26287.32.camel@lyra.fc.hp.com>
In-Reply-To: <1100550721.26287.32.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have noticed that on x86, trimming memory with "mem=" has no effect on
RAM reported by /proc/iomem. I assume we want the same behavior on ia64.
This would mean we definitely need to save an untrimmed EFI memory map.

--
Khalid

On Mon, 2004-11-15 at 15:03, David Mosberger wrote:
> >>>>> On Mon, 15 Nov 2004 13:15:25 -0800, "Luck, Tony" <tony.luck@intel.com> said:
> 
> 
>   Tony> You can add your own new requirement to not modify the
>   Tony> original EFI tables so that they can be re-scanned by a new
>   Tony> kernel after kexec (new kernel might have a different granule
>   Tony> size).
> 
> That certainly would be the right way to go about it.  It would also
> make it less likely that something else might get confused when
> changing the memory map underneath it.
> 
> 	--david
-- 

==================================
Khalid Aziz                                Linux and Open Source Lab
(970)898-9214                                        Hewlett-Packard
khalid_aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
				- Alessandro Rubini


