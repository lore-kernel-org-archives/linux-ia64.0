From: Alex Williamson <alex_williamson@hp.com>
Date: Mon, 09 Jun 2003 18:26:32 +0000
Subject: Re: [Linux-ia64] kernel message
Message-Id: <marc-linux-ia64-105590723706199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706195@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706195@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yiyang,

   You had some Corrected Machine Checks on CPU1.  Likely just single
bit errors that got corrected by ECC.  Since your error record ID is
only at 5, you haven't had too many of them.  Looks to me like the
reboot started over an hour after the CMCs, why do you think they're
related?  CMCs in small numbers are generally harmless.  If you get
them in large bursts, you'll want to use my patch that swithes to
polling to reduce system impact.

	Alex

"Dai, Yiyang" wrote:
> 
> Hi all:
> 
>     I got some kernel error messages in my rx2600 box , seems it will lead a server auto reboot .pls check attachment for detail message.
> 
>    any advise ?
> <<error@master.txt>>
> 
> Regards,
> Yiyang

-- 
Alex Williamson                             HP Linux & Open Source Lab

