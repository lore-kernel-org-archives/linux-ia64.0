From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 14 Oct 2003 23:04:15 +0000
Subject: [PATCH] sn2 module fix
Message-Id: <marc-linux-ia64-106617270703267@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Because we're the only platform with seperate in, out, and read
routines, we have to include the file that defines them in our machvec
header so that users of the functions will get the right defines and not
use the non-inline function variants (which are only necessary for
generic kernels).

Thanks,
Jesse
