From: "Mattox, Dave" <DMattox@UNITECH.COM>
Date: Fri, 20 Oct 2000 22:16:19 +0000
Subject: [Linux-ia64] Multimedia Instructions
Message-Id: <marc-linux-ia64-105590678205602@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Couple questions for you all if you don't mind:

1. Is there a mailing list for information on just IA-64? A majority of my
issues deal with the architecture exclusively and I don't want to pollute
this mailing list. If anyone knows of one I would appreciate a link.

2. Does anyone know if the 10 clock cycle penalty for a multimedia
instruction result used in a different instruction type is just a quirk of
the Itanium Chip or will this most likely be carried into future IA-64
Chipsets? If this penalty is likely to disappear in future versions, I don't
mind coding it for a hit now.

The penalty I am talking about is a code segment such as:
mux1 r36 = r37, @rev;;   // mm instruction
add r38 = 5, r36		// 10 clock penalty for using result in a
different instruction type

It's interesting how the following is actually faster:
mux1 r36 = r37, @rev;;
nop;;
nop;;
nop;;
nop;;
add r38 = 5, r36

Thanks,
Dave Mattox

