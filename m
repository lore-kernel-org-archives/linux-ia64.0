From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 17:40:18 +0000
Subject: Re: time to reconsider HZ?
Message-Id: <16878.39810.545323.698403@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16872.45685.696721.811934@napali.hpl.hp.com>
In-Reply-To: <16872.45685.696721.811934@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 08:54:09 -0800 (PST), Christoph Lameter <christoph@lameter.com> said:

  Christoph> I think its not a big issue and may still be beneficial
  Christoph> if occasions arise where one has to divide by HZ. Do you
  Christoph> know why the code size is reduced?

I assume it's because we're doing more tick -> msec than tick -> sec
conversions, but I haven't tried to verify that.  I agree that we
should first find out what the real reason for the code-size reduction
is before changing (though the "not wanting to be needlessly
different" argument still remains...).

	--david
