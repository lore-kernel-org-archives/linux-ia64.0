From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 17 Apr 2002 13:09:51 +0000
Subject: [Linux-ia64] PAL entry point
Message-Id: <marc-linux-ia64-105590701905467@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane, David,

do you agree making the symbol pal_entry_point global (included in
pal.S)? I would need access to the PAL routines directly from my program
without using the provided functions.

Thanks

Christian


