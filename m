From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 16 Jan 2002 18:24:53 +0000
Subject: Re: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805847@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Hmmm.  Let me try a different tftp server package and see if I have the
same problem.

Mike

"Luck, Tony" wrote:
> 
> Mike,
> 
> I saw the same thing a few months ago when I tried it (even when
> I replaced the elilo.efi with a 1-byte file, I still got the same
> error ... so the size of the file isn't the issue).  I didn't
> get around to chasing this ... but I wondered whether there was
> a failure to communicate the size correctly between the boot server
> that I was using (Lion running linux ... I forget which versions of
> dhcp and tftpd were present, and that machine has been re-installed
> so I can't check) and the bigsur that I was trying to boot.
> 
> -Tony Luck

