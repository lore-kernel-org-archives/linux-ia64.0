From: "Dunlap, Randy" <randy.dunlap@intel.com>
Date: Fri, 20 Apr 2001 19:53:13 +0000
Subject: RE: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005429@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005429@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ah, without actually looking at the code, I believe that
you have proven that acpidmp doesn't understand ACPI 2.0
data structures.

Sorry about that.  I don't know what the plans are for
updating acpidmp (if any).

~Randy________________________503-677-5408_____
----------------------------------------------- 

> -----Original Message-----
> From: Andreas Schwab [mailto:schwab@suse.de]
> 
> "Dunlap, Randy" <randy.dunlap@intel.com> writes:
> 
> |> At the bottom of
> |> http://developer.intel.com/technology/IAPC/acpi/downloads.htm
> 
> Thanks, this works fine for BigSur.  But on Lion I only get:
> 
> RSDP "MSLSAL" @ 0x000f57b0
>   0000: 52 53 44 20 50 54 52 20 00 4d 53 4c 53 41 4c 00  RSD 
> PTR .MSLSAL.
>   0010: 00 00 00 00                                      ....
> 
> acpidmp: cannot map the RSDT
> 
> Andreas.


