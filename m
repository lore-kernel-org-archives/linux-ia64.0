From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 09 Jun 2004 11:22:55 +0000
Subject: RE: IA64 test report: USB mouse conflict with PS2 mouse 2.4.27-pre4 /Lion 2004-6-2: 10/10 pass
Message-Id: <3ACA40606221794F80A5670F0AF15F84049913E1@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F840483B5BB@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F840483B5BB@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>So is there a problem here?  (like ps2/usb mice?)
>
>I don't see it, but there was a post on lkml 2 days ago with a
>patch to 2.6.x that may interest you.  See:
>http://marc.theaimsgroup.com/?l=linux-kernel&m8602537100592&w=2
>
>
>--
>~Randy

Hello Randy,

Thanks for the information. But I don't think the patch will help me.

I did the following experiment:

Under 2.6 kernel on Lion:
Run command:  
	gpm -t imps2 -m /dev/input/mice

USB  and PS2 mouses can live with each other 

Under 2.4 kernel on Lion:
Run command:
	gpm -t imps2 -m /dev/input/mice

Only USB mouse can work

Run command:
	gpm -t ps/2 -m /dev/psaux

Only PS2 mouse can work.

Obviously, 2.4 Input Layer cannot handle PS2 mouse. Is it normal?

Thanks,
Luming

