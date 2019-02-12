From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 12 Feb 2019 09:53:41 +0000
Subject: [PATCH 0/2] x86, numa: always initialize all possible nodes
Message-Id: <20190212095343.23315-1-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>

Hi,
this has been posted as an RFC previously [1]. There didn't seem to be
any objections so I am reposting this for inclusion. I have added a
debugging patch which prints the zonelist setup for each numa node
for an easier debugging of a broken zonelist setup.

[1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org

