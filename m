From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 07 May 2004 06:47:31 +0000
Subject: Re: [PATCH 2.6] Altix - remove node_first_cpu
Message-Id: <20040507074731.A27028@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405062305.i46N55lL278325@fsgi900.americas.sgi.com>
In-Reply-To: <200405062305.i46N55lL278325@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 06, 2004 at 06:05:05PM -0500, Pat Gefre wrote:
> -		cpu = lnodepda->node_first_cpu;
> +		cpu = sn_get_node_first_cpu(cnode);

What simply using the topology API ala:

	cpu = first_cpu(node_to_cpumask(cnode))

