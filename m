From: Martin Pool <mbp@sourcefrog.net>
Date: Tue, 13 Apr 2004 07:36:43 +0000
Subject: bug? fpswa_interface needs to be exported
Message-Id: <20040413073643.GB11350@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

In 2.6.4/5, efivars can be built as a module, but it depends on
'fpswa_interface' which is not exported by fpswa.c.  I think you need
a EXPORT_SYMBOL for that variable.

Debian's 2.6.4-mckinley-smp kernel has this built as a module but it
cannot be loaded:

  efivars: Unknown symbol fpswa_interface

Cheers,
-- 
Martin 
