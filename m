From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Sep 2002 19:15:01 +0000
Subject: [Linux-ia64] running x86 mozilla with "skin" support etc.
Message-Id: <marc-linux-ia64-105590701906046@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As you may know, the mozilla/x86 skin support pulls in dependencies on
a whole bunch x86 libraries and binaries.  Finding those dependencies
isn't entirely trivial.  I went through this exercise on my ia64
workstation and it is now set up so that mozilla/x86 works perfectly
fine (I usually prefer the native mozilla, but mozilla/x86 is still
useful for web pages that require Java, Flash, or similar plugins).

The main "trick" to get skin support working is to make sure that
/emul/ia32-linux is populated with the x86 version of /usr/bin/convert
(along with all pre-requisite libraries).  A copy of the x86 version
of the files in /usr/lib/gtk/themes/engines and /usr/lib/gdk-imlib1/
are also needed.  If someone wants a more detailed list of files, let
me know.

	--david

