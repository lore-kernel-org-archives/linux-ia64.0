From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 19:16:08 +0000
Subject: [Linux-ia64] ia32 compatibility problem
Message-Id: <marc-linux-ia64-105590693005971@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I thought I should give abiword-0.9 a try.  With the x86 binary, I get
the following kind of error messages on startup:

Gtk-WARNING **: /usr/lib/gtk/themes/engines/libpixmap.so: cannot open shared object file: No such file or directory

This is of course because libpixmap.so is an IA-64 shared library.
Seems like gtk needs to be enhanced to take the architecture into
account.

	--david

