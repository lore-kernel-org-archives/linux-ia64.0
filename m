From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 10 Sep 2001 23:28:53 +0000
Subject: RE: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805164@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Sep 2001 15:10:24 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  tony> Same test also fails in 2.4.7 ... I found a 2.4.3 kernel still
  tony> in my /boot/efi, capslock test works with that.

  tony> In 2.4.7/2.4.9 even though the caps-lock light never comes on
  tony> and the timeout message is printed, caps lock mode *is* turned
  tony> on (subsequent alphabetic chars echo in upper-case).

I suspect the problem was introduced in 2.4.7 (or thereabouts) when
the keyboard interface was changed.  I didn't notice it until a few
days ago because it only happens when working at the Linux console.
While it's not a fatal problem, it would be good if it were fixed.  A
patch would be welcome.

	--david

