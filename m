From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 04:26:47 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc2-cset-1129 hugetlb, unwind fixes
Message-Id: <marc-linux-ia64-105590723706068@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706053@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706053@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 28 May 2003 7:27 pm, Seth, Rohit wrote:
> Thanks Keith for pointing out the issue with fs/proc/proc_misc.c for
> !CONFIG_HUGETLB_PAGE.  Please use the attached small patch for
> fs/proc/proc_misc.c (as is there in 2.5).

I applied Rohit's patch (adding the #include of <linux/hugetlb.h>) to
2.4 so it's the same as 2.5.

Bjorn


