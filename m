From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 03 May 2002 17:23:02 +0000
Subject: RE: [Linux-ia64] new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905549@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 3 May 2002 08:35:59 +0100, Ross Elliott <ross.elliott@infoterra-global.com> said:

  Ross> I had this, I then re-read the system type info in Xconfig and
  Ross> set it to DIG_compliant. This solved the linking problem,
  Ross> could not get it to load though.

With the current patch, you'll have to ignore memory above the 1GB
boundary.  You can do this with the mem=1G kernel command line option.
Even so, I'm not sure whether the current patch will work.  The next
one should.

	--david

