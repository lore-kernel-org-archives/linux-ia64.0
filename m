From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 25 Jun 2001 20:26:26 +0000
Subject: Re: [Linux-ia64] panic on ia64 ; need help
Message-Id: <marc-linux-ia64-105590693005760@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005759@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005759@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 25 Jun 2001 13:32:30 -0600, "MEHTA,HIREN (A-SanJose,ex1)" <hiren_mehta@agilent.com> said:

  Hiren> But I was just wondering how I got the same return addresses
  Hiren> 4 times.

That could easily happen if the unwind info for the module is wrong.
Can you send me the .o file of the module in question?  I'd also need
to know what address the module was loaded at.

In general, if you're reporting backtraces, it would be more useful if
you included the corresponding System.map file.

	--david

