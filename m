From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 16 Jun 2004 23:01:51 +0000
Subject: Re: [PATCH] new ".serialize" gas directive
Message-Id: <16592.53599.194282.79188@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16537.51724.854691.934006@napali.hpl.hp.com>
In-Reply-To: <16537.51724.854691.934006@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 16 Jun 2004 15:42:40 -0700, Jim Wilson <wilson@specifixinc.com> said:

  Jim> Tags can't be used for control flow, so that should never have
  Jim> been an issue.

Just nit-picking: we do use tags for the Linux kernel
exception-handling purposes nowadays.  In other words: a fault will
lead to a control-flow change which may then resume execution at a
tag.

	--david
