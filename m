From: "Ameya Mitragotri" <ameya.mitragotri@wipro.com>
Date: Wed, 15 Oct 2003 11:47:09 +0000
Subject: RE: 2.6.0-Test5 booting problems on Itanium-1!
Message-Id: <marc-linux-ia64-106621874204902@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106569415603393@msgid-missing>
In-Reply-To: <marc-linux-ia64-106569415603393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> As Tony pointed out, elilo was changed a very long time ago,
> to ONLY use the *physical address* (paddr) found in the ELF 
> header of the kernel.
> 
> Elilo loads the kernel at the indicated address, if possible.
> Eventually it jumps to this address. Elilo and EFI in general 
> execute in 
> physical address mode during boot time. The beginning of the 
> actual kernel 
> execution happens in *physical mode*, the code in _start 
> (head.S) switches 
> the kernel to virtual mode. This way, we have no dependency 
> between the 
> bootloader and the kernel w.r.t. virtual mappings.

Thanks! As Tony pointed out, I did an upgrade of the elilo.

1) Installed gnu-efi-3.0-2 and elilo-3.3a-2.
2) Managed to get the 2.6.0-Test5 kernel booting started.
3) Faced panic issues coz of the qla1280 driver. Used Jes
   Sorensen's patch for the qla1280 SCSI driver.

http://www.ussg.iu.edu/hypermail/linux/kernel/0309.2/0331.html

The booting was finally successful.

Thanks
Ameya

   
