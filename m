From: "Mattox, Dave" <DMattox@UNITECH.COM>
Date: Tue, 17 Oct 2000 21:15:55 +0000
Subject: RE: [Linux-ia64] Instruction Execution
Message-Id: <marc-linux-ia64-105590678205582@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205577@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205577@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That was the problem, its now working exactly as I expected :)

Thanks for the help everyone,
Dave

-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of David Mosberger
Sent: Tuesday, October 17, 2000 10:16 AM
To: Mattox, Dave
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Instruction Execution


>>>>> On Tue, 17 Oct 2000 09:51:51 -0700, "Mattox, Dave"
<DMattox@UNITECH.COM> said:

  Dave> I just got my Itanium Machine in and after installing Linux
  Dave> (no problems with that, good work guys), I tried some timings.

  Dave> I ran a loop 666,000,000 times and it appears that each bundle
  Dave> is taking 3 seconds to execute. So this means 3 cycles per
  Dave> bundle, or 1 cycle per instruction. Is the Lion SDV Machine
  Dave> executing instructions serially? If it is, is it Linux setting
  Dave> this, or are the beta chips disabled in some manner?

Make sure "Multidispersal" is enabled in the advanced chipset
configuration menu of the firmware (BIOS).

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

