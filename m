From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 23 Sep 2004 16:43:16 +0000
Subject: Re: [Lhns-devel] [PATCH][1/4] Add unregister_node() to
Message-Id: <1095957796.21153.94.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com>
	 <20040920094719.H14208@unix-os.sc.intel.com>
	 <20040924012301.000007c6.tokunaga.keiich@jp.fujitsu.com>
	 <20040924013123.000067cd.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040924013123.000067cd.tokunaga.keiich@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: anil.s.keshavamurthy@intel.com, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 2004-09-23 at 09:31, Keiichiro Tokunaga wrote:
> -int __init register_node(struct node *node, int num, struct node *parent)
> +int register_node(struct node *node, int num, struct node *parent)

__devinit, please.

-- Dave

