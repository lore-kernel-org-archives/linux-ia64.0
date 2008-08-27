From: Artem Bityutskiy <dedekind@yandex.ru>
Date: Wed, 27 Aug 2008 14:55:22 +0000
Subject: Re: [PATCH 01/59] CRED: Wrap task credential accesses in the IA64
Message-Id: <48B56ADA.8010808@yandex.ru>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080827134541.19980.61042.stgit@warthog.procyon.org.uk> <20080827134547.19980.38813.stgit@warthog.procyon.org.uk>
In-Reply-To: <20080827134547.19980.38813.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

David Howells wrote:
> Wrap access to task credentials so that they can be separated more easily from
> the task_struct during the introduction of COW creds.
> 
> Change most current->(|e|s|fs)[ug]id to current_(|e|s|fs)[ug]id().
> 
> Change some task->e?[ug]id to task_e?[ug]id().  In some places it makes more
> sense to use RCU directly rather than a convenient wrapper; these will be
> addressed by later patches.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Reviewed-by: James Morris <jmorris@namei.org>
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: linux-ia64@vger.kernel.org

Fine with me. Do you want us to put this patch to ubifs-2.6.git or you
prefer to make it go together with the rest of the CRED patches?

-- 
Best Regards,
Artem Bityutskiy (Артём Битюцкий)
