From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jan 2005 21:59:08 +0000
Subject: Re: patch to fix recent percpu mca changes which broke CPU hotplug
Message-Id: <16890.46508.276748.753196@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050128125301.A16685@unix-os.sc.intel.com>
In-Reply-To: <20050128125301.A16685@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 Jan 2005 12:53:01 -0800, Ashok Raj <ashok.raj@intel.com> said:

  Ashok> Hi Tony Recent mca percpu changes broke a cpu being brought
  Ashok> up after initial boot which is required for cpu hotplug.

Argh, I _briefly_ wondered about, but forgot about it before checking on it.
Sorry about that.

	--david
