From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 07 Nov 2007 09:46:01 +0000
Subject: Re: [PATCH 1/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <47318959.2080306@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BDC7.1070702@jp.fujitsu.com>
In-Reply-To: <4714BDC7.1070702@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I did run the kernel some more today and noticed some odd "hangs".
> Some processes seemed to get stuck for many seconds and then
> continued again.  Didn't have time to try and track what was
> happening.  Have you seem snything like this?
> 

I've encountered the similar phenomenon several times. I have
not investigated it very much, but I guess it is related to the
problem reported at

http://marc.info/?l=linux-kernel&m9303432628668&w=2

The 'wa' field of 'top' command showed that one of cpus is under
100% iowait when I encountered the problem.

Thanks,
Kenji Kaneshige

