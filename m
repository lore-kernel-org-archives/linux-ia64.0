From: "Howell, David P" <david.p.howell@intel.com>
Date: Mon, 14 Apr 2003 22:13:54 +0000
Subject: RE: [Linux-ia64] kernel update (relative to v2.5.67)
Message-Id: <marc-linux-ia64-105590723705499@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks. I did get by my initial PCI/ACPI config problems with this
patch.

Dave Howell


These are my opinions and not official opinions of Intel Corp.

David Howell
Intel Corporation
Telco Server Development
Server Products Division
Voice: (803) 461-6112  Fax: (803) 461-6292

Intel Corporation
Columbia Design Center, CBA-2
250 Berryhill Road, Suite 100
Columbia, SC 29210

david.p.howell@intel.com


-----Original Message-----
From: Alex Williamson [mailto:alex_williamson@hp.com] 
Sent: Monday, April 14, 2003 4:57 PM
To: davidm@hpl.hp.com
Cc: Takayoshi Kochi; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.67)

David Mosberger wrote:
> 
> >>>>> On Mon, 14 Apr 2003 21:55:19 +0900 (JST), Takayoshi Kochi
<kochi@hpc.bs1.fc.nec.co.jp> said:
> 
>   Takayoshi> It seems that newly integrated PCI segment support is
>   Takayoshi> incomplete.
> 
> Argh.  Alex, can you work this out?  If fixing the segment support is
> too much effort right now, we need to revert the segment support so
> the kernel boots on Big Sur (and Tiger) again.
> 

   This patch makes it work on my i2000.  There's definitely still
some issues, but I'd rather get something out that works and go from
there, than revert it.  Please test and let me know what else you
find.  Thanks,

	Alex

--
Alex Williamson                             HP Linux & Open Source Lab

