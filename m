From: Keith Owens <kaos@melbourne.sgi.com>
Date: Thu, 28 Jun 2001 00:05:27 +0000
Subject: [Linux-ia64] kdb v1.8a-2.4.5-ia64-010626
Message-Id: <marc-linux-ia64-105590693005793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 27 Jun 2001 00:09:08 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>The latest IA-64 patch is available at:
> ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/
>in file linux-2.4.5-ia64-010626.diff*.

kdb-v1.8a-2.4.5-ia64-010626 is available in
ftp://oss.sgi.com/projects/kdb/download/ia64.

kdb is being upgraded with some new features for better automatic bug
reporting, this is a partial release, hence 1.8a.

The major change from 1.8 to 1.8a is the addition of longjmp() support
for kdb.  The LINES parameter is now honoured so you can quit out of a
long set of output, set LINES=0 to get no paging.  The big advantage of
longjmp() support is that kdb can now attempt to recover from internal
errors, including bad addresses.  See also variable RECURSE in
Documentation/kdb/kdb.mm.


