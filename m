From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 31 Mar 2004 18:33:38 +0000
Subject: Re: context-switch on IA64
Message-Id: <16491.3842.685223.999292@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040331100307.GA1303@foudroyante.lifl.fr>
In-Reply-To: <20040331100307.GA1303@foudroyante.lifl.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 31 Mar 2004 12:03:08 +0200, Julien.Soula@lifl.fr said:

  Julien> So the question is : how the task has been re-activated during a
  Julien> context_switch ?

Note that prepare_arch_switch() drops the runqueue lock.

	--david
