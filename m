From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 13 Oct 2003 17:30:07 +0000
Subject: Re: 2.6.0-Test5 booting problems on Itanium-1!
Message-Id: <marc-linux-ia64-106606663708273@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106569415603393@msgid-missing>
In-Reply-To: <marc-linux-ia64-106569415603393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

As Tony pointed out, elilo was changed a very long time ago, to ONLY
use the *physical address* (paddr) found in the ELF header of the kernel.

Elilo loads the kernel at the indicated address, if possible. Eventually
it jumps to this address. Elilo and EFI in general execute in 
physical address mode during boot time. The beginning of the actual kernel 
execution happens in *physical mode*, the code in _start (head.S) switches 
the kernel to virtual mode. This way, we have no dependency between the 
bootloader and the kernel w.r.t. virtual mappings.

-- 
-Stephane
