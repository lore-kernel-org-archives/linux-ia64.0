From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Feb 2005 19:53:30 +0000
Subject: Re: What contributes to IA64 ITC/TOD drift?
Message-Id: <16906.27194.372672.998370@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E01120E12@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E01120E12@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Feb 2005 18:27:01 -0800, "John Lee" <jlee@platsolns.com> said:

  John> Maybe too broad a question but,

  John> 1. What in IA64 platform contributes to ITC drift?

Are you asking when the IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT bit should
be set?  If so, then the answer is that it should be set whenever the
ITC clocks of the processors in a machine are not driven off the same
oscillator.

  John> 2. What in IA64 platform contributes to TOD fluctuation?
  John> (excluding the quality of oscillator)

NTP comes to mind.  Any other error I can think of probably would lead
to a systematic error, not to fluctuations.

	--david
