From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 31 Oct 2002 18:08:34 +0000
Subject: Re: [Linux-ia64] psr rt bit
Message-Id: <marc-linux-ia64-105590709805319@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805315@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805315@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 31 Oct 2002 10:20:49 -0600, Mario Smarduch <cms063@email.mot.com> said:

  Mario> In head.S ipsr 'rt' bit along with other bits is set before
  Mario> rfi as the initialization goes to virtual mode. As the 'rfi'
  Mario> implicitly updates the 'psr' will that cause problems if
  Mario> 'rsc' is not in lazy mode?

Yes.

  Mario> Is it assumed that 'rsc' is in lazy mode by the time _start
  Mario> runs?

Yes.  SAL Section 3.2.5 guarantees that ar.rsc is set to "enforced
lazy mode, little-endian".

	--david

