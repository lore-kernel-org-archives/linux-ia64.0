From: "Dunlap, Randy" <randy.dunlap@intel.com>
Date: Thu, 19 Apr 2001 15:22:23 +0000
Subject: RE: [Linux-ia64] Re: Detecting SMP in user space
Message-Id: <marc-linux-ia64-105590693005433@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005429@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005429@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At least on i386, root can read the ACPI tables from
/dev/mem (as done in the pmtools [acpitools] package).


~Randy________________________
-----------------------------------------------

> -----Original Message-----
> From: Andreas Schwab [mailto:schwab@suse.de]
> Sent: Thursday, April 19, 2001 7:31 AM
> To: Don Dugger
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Re: Detecting SMP in user space
> 
> 
> Don Dugger <n0ano@valinux.com> writes:
> 
> |> Andreas-
> |> 
> |> On my system the boot messages are copied into `/var/log/messages'
> |> so you can always go there even if the boot log is cleared.
> 
> This is not reliable.  I need something that I can use 
> without depending
> on the kernel messages.  Is it possible to get at the ACPI 
> tables in user space?
> 
> Andreas.


