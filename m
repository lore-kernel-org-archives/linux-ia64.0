From: "JWM" <jwm@systemfabricworks.com>
Date: Tue, 26 Sep 2006 16:55:36 +0000
Subject: EFI returning incorrect value?
Message-Id: <004001c6e18c$972938d0$7401a8c0@Maelstrom>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Hi all;

    I've been trying to work through issues related to write combining on a 
Bull Ia64 system and something caught my attention.
    efi_range_is_wc returns a 0 - false or 1- true to say whether the 
address range is available for write combining.
    It calls efi_mem_attributes i.e.

    if(!(efi_mem_attributes(paddr) & EFI_MEMORY_WC))
            return 0;

    However - the attribute returned from efi_mem_attributes is often 0 - 
which is defined as EFI_MEMORY_RUNTIME - or the range requires a runtime 
mapping. This doesn't seem to be what was wanted - unless EFI must have a 
mapping on this platform before WC is available for some reason.

    Can anyone enlighten me on this?
    ....JW

 

