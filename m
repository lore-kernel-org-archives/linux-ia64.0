From: Jes Sorensen <jes@wildopensource.com>
Date: Thu, 03 Mar 2005 12:53:37 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <yq0r7iwevqm.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<20050303033704.6fb77a34.akpm@osdl.org>
In-Reply-To: <20050303033704.6fb77a34.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Andrew" = Andrew Morton <akpm@osdl.org> writes:

Andrew> jes@trained-monkey.org (Jes Sorensen) wrote:
>>  This patch introduces ia64 specific read/write handlers for
>> /dev/mem access which is needed to avoid uncached pages to be
>> accessed through the cached kernel window which can lead to random
>> corruption.

Andrew> This patch causes hiccups on my ia32e box.

Andrew> linux:/home/akpm# /usr/sbin/hwscan --isapnp zsh: 7528
Andrew> segmentation fault

Weird, I'll take a look.

Thanks,
Jes

