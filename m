From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 05 Dec 2003 00:54:19 +0000
Subject: RE: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107058568316184@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What does:
	# objdump -fp vmlinux
say?

What version of elilo are you running? (Run "elilo -v" from the EFI prompt, I think).

-Tony

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Bill Nottingham
> Sent: Thursday, December 04, 2003 1:56 PM
> To: linux-ia64@vger.kernel.org
> Subject: can't boot 2.6.0-test11
> 
> 
> Trying to boot a 2.6test ia64 kernel here, I'm getting:
> 
> Loadin vmlinux...Loading Linux... 
> alloc.c(line 132):allocator: AllocatePages(2, 2, 
> 3377699721561477, 0x40000000) failed (Not Found)
> plain_loader.c(line 291):plain_elf64: 
> AllocatePages(3377699721561477, 0x40000000) for kernel failed
> 
> Is the kernel just horribly misbuilt somehow, or is something else
> going on?
> 
> Bill
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
