From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Nov 2003 23:32:34 +0000
Subject: Re: Problems using psr.dd
Message-Id: <marc-linux-ia64-106937136916250@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106879020623297@msgid-missing>
In-Reply-To: <marc-linux-ia64-106879020623297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 21 Nov 2003 10:15:55 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Arch volume 2, section 5.3 is quite explicit, "A non-faulting
  Keith> mandatory RSE load will clear PSR.da and PSR.dd".

Ah, I see, that clears it up, then.  I had forgotten about this
behavior.  No mystery then.

Thanks,

	--david
