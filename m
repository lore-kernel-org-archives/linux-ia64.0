From: Andrew Morton <akpm@osdl.org>
Date: Mon, 04 Oct 2004 06:26:59 +0000
Subject: current ia64 tree goes oom
Message-Id: <20041003232659.32275e1f.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The good news is that my 4-way 1G Tiger machine now boots a bit.

The bad news is that it runs out of memory partway through boot.  It's
rather odd.

Boot log: http://www.zip.com.au/~akpm/linux/patches/stuff/minicom.cap
.config: http://www.zip.com.au/~akpm/linux/patches/stuff/config-ia64
