From: Bruno Vidal <bruno_vidal@hp.com>
Date: Tue, 13 May 2003 14:39:30 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705758@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Hi
Sorry, but LKCD is really not usefull because it use the buffer
to write on the device. So it just hang in case of data page fault for
example (because interuption are masked), LKCD is also not working in case
of buffer corruption, disk driver pb, etc.... so LKCD is not usable in
lot's of case (and it happen really often to have data page fault).

Cheers.

Howell, David P wrote:
> Have you looked at the LKCD project? It supports ia64 and does about
> what you are doing on the dump side, and has dump analysis tools.
> 
> If you've already considered this just delete this.
> 
> Thanks,
> Dave Howell
> 
> 
> These are my opinions and not official opinions of Intel Corp.
> 
> David Howell
> Intel Corporation
> Telco Server Development
> Server Products Division
> Voice: (803) 461-6112  Fax: (803) 461-6292
> 
> Intel Corporation
> Columbia Design Center, CBA-2
> 250 Berryhill Road, Suite 100
> Columbia, SC 29210
> 
> david.p.howell@intel.com
> 
> 
> -----Original Message-----
> From: Bruno Vidal [mailto:bruno_vidal@hp.com] 
> Sent: Tuesday, May 13, 2003 3:03 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] Dump driver module
> 
> 	Hi all.
> I've already wrote a dump modules driver for linux-parisc.
> This module goal is to create a memory image on a swap area, and
> at reboot time to save it to disk with all kernel modules, in
> order to analyze it after by "support" people with tools like
> gdb/p4. The problem while dumping is that the dump modules
> cannot trust anymore the system, so dumping means: no interruption,
> no disk driver, no buffer, nothing. The solution is to use low level
> call. For parisc I use the IODC calls, for ia64 I think I'll
> use the EFI calls. My questions:
> -do you think it is a "good" and realistic solution.
> -because I think "yes", does exist somewhere an example of
> reading/writing with EFI call on disk using BLOCK IO. I've already
> looked in elilo, but it seems that it use FS access.
> 
> 	Thanks.
> 


-- 
	Vidal Bruno, (770-4271)
         SSD-HA Team, HP-UX & LINUX Support
	bruno_vidal@hp.com


