From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Apr 2004 22:13:26 +0000
Subject: Re: [PATCH] module relocation code
Message-Id: <16518.61958.903544.253058@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Apr 2004 23:56:01 +0200 (CEST), Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net> said:

  Jean-Marc> I suspect that other types of relocation that use "short"
  Jean-Marc> GP- or IP-relative offsets have the same problem, but
  Jean-Marc> first I'd like to have confirmation from people who are
  Jean-Marc> more knowledgeable on this.

Your analysis sounds correct to me.

  Jean-Marc> Here is a fix for R_IA64_PCREL21B (should apply to 2.6.5
  Jean-Marc> as is):

Apart from formatting issues, I didn't see where/how the patch handles
the case in_core() && !in_init(), but that's just based on a quick read.

	--david
