From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 18 Jul 2001 21:32:26 +0000
Subject: Re: [Linux-ia64] atomic add instruction
Message-Id: <marc-linux-ia64-105590693005853@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There are compiler intrinisics for this purpose.  See the IA-64
processor-specific ABI for a description.  You have to include
<ia64intrin.h> to get the intrinsics defined.

	--david

>>>>> On Tue, 17 Jul 2001 15:09:46 -0700, "Swaminathan Sivasubramanian" <ssivasu@us.ibm.com> said:

  Swami> Hello Everyone,

  Swami> I want an atomic function that does addition of a constant to
  Swami> the value in a memory location and returns the previous value
  Swami> in that location.

  Swami>  Is there any macro/function defined in IA-64's atomic.h
  Swami> already. (will fetch-and-add solve the purpose?) or one
  Swami> should write his own function for it

  Swami> Thanking in advance, Swami



  Swami> _______________________________________________ Linux-IA64
  Swami> mailing list Linux-IA64@linuxia64.org
  Swami> http://lists.linuxia64.org/lists/listinfo/linux-ia64

