From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Thu, 21 Feb 2002 22:02:19 +0000
Subject: RE: [Linux-ia64] Poweroff
Message-Id: <marc-linux-ia64-105590701905165@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905158@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905158@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's been working for BigSur for long but Lion needed some more work.
I've sent iosapic and acpi patch against 2.4.17 to David that enables ACPI
softoff on Lion.
halt -p power-offs with that patch.

thanks,
J.I.

-----Original Message-----
From: KOCHI, Takayoshi [mailto:t-kouchi@mvf.biglobe.ne.jp]
Sent: Thursday, February 21, 2002 10:01 AM
To: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Poweroff



On Thu, 21 Feb 2002 13:32:00 +0100
Jacqueline Lemaitre <Jacqueline.Lemaitre@bull.net> wrote:

> poweroff is not yet implemented on an ia64 machine.
> Is there anybody aware of it ?

If a machine implements ACPI functionality (both hardware and
firmware),  powering off should work fine.  At least
poweroff command works on NEC's AzusA.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

