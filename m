From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 27 Oct 2003 22:38:59 +0000
Subject: Re: Compilation fix for UP I2000
Message-Id: <marc-linux-ia64-106729464327748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106729391426813@msgid-missing>
In-Reply-To: <marc-linux-ia64-106729391426813@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 28 Oct 2003 09:17:13 +1100, Peter Chubb <peterc@gelato.unsw.edu.au> said:

  Peter> Hi, The variable `foo' was deleted in a recent changeset, but
  Peter> one reference was missed.  I needed the appended patch to get
  Peter> a good compilation for uniprocessor I2000.

Yes, unfortunately.  Stephane already sent me a patch and it's in the
to-linus-2.5 tree already.

	--david
