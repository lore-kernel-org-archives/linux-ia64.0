From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 30 May 2002 03:55:49 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905616@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 May 2002 10:18:43 -0700, Rich Altmaier <richa@engr.sgi.com> said:

  Rich> David, FYI, I asked our hardware designers about current
  Rich> oscillator accuracy and was a bit suprised to learn that one
  Rich> pays a premium price today to get 300ppm.  600ppm can happen
  Rich> in lower cost units.

Thanks for sharing that.  I just tried the obvious google search for
"crystal ppm" and most of the hits where for crystals on the order of
30-50ppm, with the occasional 100ppm.  Precision crystals seem to be
rated at <1ppm.  So, 600ppm seems a bit on the high side, but I guess
it's not totally unreasonable either.  I guess NTP is our
friend... ;-)

	--david

