From: "Saxena, Sunil" <sunil.saxena@intel.com>
Date: Mon, 23 Oct 2000 14:47:22 +0000
Subject: RE: [Linux-ia64] Multimedia Instructions
Message-Id: <marc-linux-ia64-105590678205608@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205602@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205602@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Dave,

Here is the answer I got from the architecture team.

Thanks
Sunil

     > -----Original Message-----
     > From: Mattox, Dave [mailto:DMattox@UNITECH.COM]
     > Sent: Friday, October 20, 2000 3:16 PM
     > To: 'linux-ia64@linuxia64.org'
     > Subject: [Linux-ia64] Multimedia Instructions
     > 
     > 
     > Couple questions for you all if you don't mind:
     > 
     > 1. Is there a mailing list for information on just 
     > IA-64? A majority of my
     > issues deal with the architecture exclusively and I 
     > don't want to pollute
     > this mailing list. If anyone knows of one I would 
     > appreciate a link.
I dont' know about a mailing list, but Sathya should know if
there is anything official.

     > 2. Does anyone know if the 10 clock cycle penalty for a 
     > multimedia
     > instruction result used in a different instruction type 
     > is just a quirk of
     > the Itanium Chip or will this most likely be carried 
     > into future IA-64
     > Chipsets? If this penalty is likely to disappear in 
     > future versions, I don't
     > mind coding it for a hit now.
This penalty is likely to be Itanium specific and hopefully will
NOT be present on future products.  However, I would still consider
the stops as those 10 cycle penalties can *really* hurt if they
are in a warm to hot region of code.

     > 
     > The penalty I am talking about is a code segment such as:
     > mux1 r36 = r37, @rev;;   // mm instruction
     > add r38 = 5, r36		// 10 clock penalty for using 
     > result in a
     > different instruction type
     > 
     > It's interesting how the following is actually faster:
     > mux1 r36 = r37, @rev;;
     > nop;;
     > nop;;
     > nop;;
     > nop;;
     > add r38 = 5, r36
     > 
     > Thanks,
     > Dave Mattox
     > 
     > _______________________________________________
     > Linux-IA64 mailing list
     > Linux-IA64@linuxia64.org
     > http://lists.linuxia64.org/lists/listinfo/linux-ia64
     > 


