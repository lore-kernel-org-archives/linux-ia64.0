From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 14 Oct 2004 17:53:05 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <416EBD01.3010708@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com> <20041007142710.A12688@infradead.org> <4165D4C9.2040804@intel.com> <mailman.1097223239.25078@unix-os.sc.intel.com> <41671696.1060706@intel.com> <mailman.1097403036.11924@unix-os.sc.intel.com> <416AF599.2060801@intel.com> <1097617824.5178.20.camel@localhost.localdomain> <416C5ECF.6060402@intel.com> <20041014085003.GM31909@devserv.devel.redhat.com>
In-Reply-To: <20041014085003.GM31909@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Jelinek <jakub@redhat.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On 10/14/2004 1:50 AM, Jakub Jelinek wrote:

> There is no point in calling __emul_prefix () when it will be thrown away.

This is addressed in the most recent patch posted to the mailing list.

	-Arun
