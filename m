From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 10 May 2004 18:22:26 +0000
Subject: Re: flushrs and the backing store
Message-Id: <16543.51298.744463.19937@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040510175934.51397.qmail@web60008.mail.yahoo.com>
In-Reply-To: <20040510175934.51397.qmail@web60008.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 May 2004 10:59:34 -0700 (PDT), umut aymakoglu <umutaymak@yahoo.com> said:

  Umut> Hi - Is there some kind of documentation that talks about what
  Umut> registers are saved in the backing store up to the current
  Umut> procedure after flushrs instruction and their
  Umut> layout/structure?

Sure, the ASDM [1] does.  As does my book (with better figures,
IMHO... ;-) But really, it's quite simple: flushrs writes back all
stacked registers in the dirty partition.  The backing store format
consists of naturally-aligned 64-word blocks (512 bytes), with the
first 63 words use to store register values and the 64-th word use to
store the NaT bits of the first 63 words.

	--david

[1] http://www.intel.com/design/itanium/manuals/iiasdmanual.htm
