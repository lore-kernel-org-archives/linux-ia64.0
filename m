From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Wed, 13 Sep 2006 02:27:59 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <A8C6D6DC3AF448indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11 Sep 2006 14:12:13 +0800, Zou Nan hai wrote:

>	I am not quite sure though, if OS_INIT is happened during a module
>execution, or happened when system is in user space, what GP value will
>be passed from SAL/PAL? If the gp value is the physical address of the
>modules 's gp, we can't set GP value according to that, because
>ia64_init_handler is inside kernel.

When OS_INIT handler is called from SAL, gp register is always
set to the value which is specified by ia64_sal_set_vectors,
I think.

Regards,
Takao Indoh

