From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Feb 2003 01:50:41 +0000
Subject: [Linux-ia64] Re: strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805911@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805910@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805910@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 24 Feb 2003 12:45:10 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> generated a two bundle loop as you suggested, but BogoMIPS went down,
  Keith> not up.

Note: 2 bundle != 2 cycle, but even ignoring that: what did you
expect?  BogoMIPS counts 2 instructions per loop iteration no matter
how many instructions are being executed.  Perhaps you can get the
compiler to unroll the loop.  Then you'd see a higher BogoMIPS.

	--david

