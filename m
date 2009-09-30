From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 30 Sep 2009 20:47:04 +0000
Subject: RE: [PATCHSET percpu#for-next] percpu: convert ia64 to dynamic percpu
Message-Id: <alpine.DEB.1.10.0909301644460.9271@gentwo.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org> <4AC153EA.2050007@suse.de> <57C9024A16AD2D4C97DC78E552063EA3E2F03E58@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3E2F03E58@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Tejun Heo <teheo@suse.de>, Nick Piggin <npiggin@suse.de>, "Yu, Fenghua" <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


Great. Ill post a new rev of the per cpu ops patchset.

Tony: Could we use a global register for the per cpu address? That would
make IA64 work similar to sparc.


