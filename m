From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 19 Jun 2003 18:30:52 +0000
Subject: Re: [Linux-ia64] Compiling kernel 2.4.21 on HP zx6000
Message-Id: <marc-linux-ia64-105604755806360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604697305688@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604697305688@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 19 June 2003 12:20 pm, ia64@OXYGEN.chem.nthu.edu.tw wrote:
> 	Has anybody ever succeeded in compiling kernel 2.4.21 over HP zx6000
> workstations, running RedHat AW 2.1?

No.  You can't build an ia64 kernel from the unmodified 2.4.21 source.
You have to first apply the ia64 patch (which I haven't released yet).

Bjorn


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
