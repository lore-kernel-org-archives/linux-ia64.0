From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Aug 2003 06:04:59 +0000
Subject: Re: [PATCH] sn2 module (& other misc.) fixes
Message-Id: <marc-linux-ia64-106006356510283@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106003174416756@msgid-missing>
In-Reply-To: <marc-linux-ia64-106003174416756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 4 Aug 2003 18:15:58 -0700, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> What needs to be done to fix the assembler?  It always spews
  Jesse> a bunch of warnings during the build.  The ia64 build would
  Jesse> be really quiet if that was fixed...

We need to add directives to let the assembler know that the code is
indeed safe.

	--david
