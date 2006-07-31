From: Jes Sorensen <jes@sgi.com>
Date: Mon, 31 Jul 2006 13:13:55 +0000
Subject: Re: [PATCH 0/2] Fix RAID5 + IA64 compile
Message-Id: <44CE0213.8030204@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060728140145.9149.43458.sendpatchset@prarit.boston.redhat.com> <yq01ws29li9.fsf@jaguar.mkp.net> <44CE01AB.8040205@redhat.com>
In-Reply-To: <44CE01AB.8040205@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>
Cc: linux-ia64@vger.kernel.org, linux-raid@vger.kernel.org

Prarit Bhargava wrote:
> Resubmitting ... please note this patch is ia64 ONLY.

> ------------------------------------------------------------------------
> 
> CONFIG_MD_RAID5 became CONFIG_MD_RAID456 in drivers/md/Kconfig.  Make the same
> change in arch/ia64
> 
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Signed-off-by: Aron Griffis <aron@hp.com>

Acked-by: Jes Sorensen <jes@sgi.com>

I like this one much better :-)

Jes
