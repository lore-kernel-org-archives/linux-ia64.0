From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 10 May 2002 05:27:55 +0000
Subject: [Linux-ia64] Re: new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 May 2002 10:49:56 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>	linux-2.4.18-ia64-020508.diff.gz
>	o Updated Fusion driver (needed for some of HP's zx1 platforms)

That change has introduced drivers/message/fusion/utils.  None of that
code belongs in the kernel, it is not hooked into the kernel build
system.  Whoever added drivers/message/fusion/utils, please remove it.


