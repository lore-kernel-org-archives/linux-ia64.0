From: Horms <horms@verge.net.au>
Date: Fri, 25 May 2007 04:17:51 +0000
Subject: Re: [PATCH] ia64-acpi section mismatch
Message-Id: <20070525041751.GS26510@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070524112210.307857c7.randy.dunlap@oracle.com>
In-Reply-To: <20070524112210.307857c7.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 24, 2007 at 11:22:10AM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> On 2.6.22-rc2-git5:
> WARNING: arch/ia64/kernel/built-in.o(.text+0x12): Section mismatch: reference to .init.text:acpi_find_rsdp (between 'acpi_get_sysname' and 'acpi_request_vector')
> 
> Looks like acpi_get_sysname() can be marked __init...

It seems like Tony has put the same fix in.
In any case, no warnings over here on
Linus' 1c1ee4c3e7e16d23166a624a132889df3c540a18

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

