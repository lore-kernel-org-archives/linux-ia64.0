From: Bruno Vidal <bruno_vidal@hp.com>
Date: Tue, 13 May 2003 07:38:05 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705754@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


David Mosberger wrote:
>>>>>>On Tue, 13 May 2003 09:02:48 +0200, Bruno Vidal <bruno_vidal@hp.com> said:
>>>>>
> 
>   Bruno> I've already wrote a dump modules driver for linux-parisc.
>   Bruno> This module goal is to create a memory image on a swap area, and
>   Bruno> at reboot time to save it to disk with all kernel modules, in
>   Bruno> order to analyze it after by "support" people with tools like
>   Bruno> gdb/p4. The problem while dumping is that the dump modules
>   Bruno> cannot trust anymore the system, so dumping means: no interruption,
>   Bruno> no disk driver, no buffer, nothing. The solution is to use low level
>   Bruno> call. For parisc I use the IODC calls, for ia64 I think I'll
>   Bruno> use the EFI calls. My questions:
>   Bruno> -do you think it is a "good" and realistic solution.
>   Bruno> -because I think "yes", does exist somewhere an example of
>   Bruno> reading/writing with EFI call on disk using BLOCK IO. I've already
>   Bruno> looked in elilo, but it seems that it use FS access.
> 
> Once the kernel is booted, you can access only the EFI runtime
> services (see struct efi in include/linux/efi.h).  I'm afraid there is
> no support for writing disk blocks.  Given this limitation, I suspect
> you'd have to include your own (simple) disk driver(s).
> 
> 	--david
> 
> .
> 

I've already seen this EFI runtime service, and there is nearly nothing in it
(nothing usefull for IO), so what I can understand is I have to write (rewrite)
a driver for each kind of scsi/ide interface....it is not really realistic :-(
There is no other way to access EFI or firmware ? Or reset back EFI to have access
to BLOCK IO interface ? For example in parisc, the first thing to do, is to a
do a PDC_IO_RESET, it freeze the entire system and it is possible to have access
to all firmware calls. Does exist something similar with EFI.

	Thanks.

-- 
	Vidal Bruno, (770-4271)
         SSD-HA Team, HP-UX & LINUX Support
	bruno_vidal@admin.france.hp.com


