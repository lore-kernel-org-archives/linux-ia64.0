From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Apr 2004 22:49:57 +0000
Subject: Re: bug? fpswa_interface needs to be exported
Message-Id: <16508.28309.357059.472234@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413073643.GB11350@hp.com>
In-Reply-To: <20040413073643.GB11350@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Apr 2004 17:36:43 +1000, Martin Pool <mbp@sourcefrog.net> said:

  Martin> Hi, In 2.6.4/5, efivars can be built as a module, but it
  Martin> depends on 'fpswa_interface' which is not exported by
  Martin> fpswa.c.  I think you need a EXPORT_SYMBOL for that
  Martin> variable.

  Martin> Debian's 2.6.4-mckinley-smp kernel has this built as a
  Martin> module but it cannot be loaded:

  Martin>   efivars: Unknown symbol fpswa_interface

Want to send a (tested) patch?

	--david
