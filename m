From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 11 Jun 2001 17:23:08 +0000
Subject: Re: [Linux-ia64] Linux 2.4.5 boot hangs at  "SCSI(0): Verifying chip"
Message-Id: <marc-linux-ia64-105590693005707@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005705@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005705@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make sure that the SCSI adapter is set to 64bit addressing.

On Mon, Jun 11, 2001 at 09:17:41AM -0700, Robboy, David G wrote:
> Booting Linux 2.4.5 on a Lion, it sometimes hangs at "SCSI(0): Verifying
> chip..."  When it hangs there, you can't break in with ITP, it gets a bus
> timeout. Other times, it boots.  Has anyone else seen this?  If so, is it a
> known problem with Linux, firmware, or what?  Is there a workaround?
> 
> Thanks,
> David Robboy
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Mike Madore
Senior Software Engineer
TurboLinux, Inc.
(650)228-5203

