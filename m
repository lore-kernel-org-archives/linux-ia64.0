From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 14 Aug 2001 08:19:43 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.8)
Message-Id: <marc-linux-ia64-105590698805071@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.8-ia64-010814.diff*.

One major improvement in this patch is that the machine check support
(MCA code) should work again and better.  Thanks to Asit & crew.  Note
that Linus switched to the DRM code needed for XFree86-4.1.  But since
we don't 460gx have AGP support for this version yet and since most
folks are presumably still running 4.0.x, I kept the old DRM code
instead.  I assume this will stay so until someone (Chris?) has had a
chance up update the 460gx code to 4.1.

Oh, I dropped support for B0-B2 CPUs.  So now, only B3 or newer CPUs
are supported.

Enjoy,

	--david

