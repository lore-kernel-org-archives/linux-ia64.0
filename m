From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 11 Oct 2001 03:21:34 +0000
Subject: RE: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805331@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Oct 2001 20:11:58 -0700, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  >> Can you be more specific?  A machine should easily tolerate a
  >> rate of one logged message per second, so if this makes a
  >> significant performance difference, that would be strange.

  Asit> We saw a 2-5% performance degradation of specfp benchmarks
  Asit> when the logging was enabled. I can take a look at this again
  Asit> and see how often the FPSWA messages are getting logged.

On which one?  Speed or throughput?

	--david

