From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 23 Jul 2004 13:50:46 +0000
Subject: Re: take2: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <410117B6.8020304@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE09B5.7020109@jp.fujitsu.com>
In-Reply-To: <40FE09B5.7020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>   o How to prepare multiple 'irq_desc' arrays for each vector domains
> 
> 
> No sure what this means offhand...but assume it's just more code.

Sorry... I was a little confused.
What we need to prepare is vector spaces for each domain. So what
we need to change is 'iosapic_intr_info' array, assign_irq_vector(),
and so on..

Thanks,
Kenji Kaneshige

